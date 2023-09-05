


Function Global:IPV4ToUint32([IPAddress]$ip)
{
  $bytes = $ip.GetAddressBytes()
  if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes)
  }
  return [BitConverter]::ToUInt32($bytes, 0)
}

Function Global:TestSameNetwork
{
  Param
  (
    [IPAddress]$ip1,
    [IPAddress]$ip2,
    [Int]$submaskCidrBits
  )
  Begin
  {
    $commonBits =32 - $submaskCidrBits
    $commonValue =[Math]::Pow(2, $commonBits)
    $aint = IPV4ToUint32($ip1)
    $a = $aint - ($aint % $commonValue)
    $bint = IPV4ToUint32($ip2)
    $b = $bint - ($bint % $commonValue)
    Write-Debug ("$ip1 $ip2 $aint $a $bint $b $submaskCidrBits $commonBits $commonValue")
    Return $a -eq $b
  }
}


Function Global:New-MultipassVMIPFixe
{
    <#.SYNOPSIS
    Fonction Powershell pour créer une nouvelle VM avec une adresse IP fixe
    .DESCRIPTION
    vmName          : nom de la vm
    vmIP            : adresse IP fixe de la VM
    submaskCidrBits : nombre de bits notation CIDR (default=24)
    switchName      : nom du switch virtuel existant ou à créer (default=multipass)
    switchIp        : adresse IP du switch virtuel existant ou à créer (default=192.168.10.254)
    launchArgs      : paramètres envoyés à multipass launch
    .EXAMPLE
    New-MultipassVMIPFixe -vmName ipfix -vmIP 192.168.10.7
    New-MultipassVMIPFixe -vmName ipfix -vmIP 192.168.10.7 -launchArgs "-d 20G -m 2G"
    New-MultipassVMIPFixe -vmName ipfix -vmIP 192.168.10.7 -launchArgs "--cloud-init lamp.yaml"
    #>
    Param
    (
        [Parameter(Mandatory,HelpMessage='Nom de la VM : ')]
        [String]$vmName,
        [Parameter(Mandatory,HelpMessage='Adresse IP de la VM : ')]
        [IPAddress]$vmIP,
        [Int]$submaskCidrBits=24,
        [String]$switchName="multipass",
        [IPAddress]$switchIp="192.168.10.254",
        [String]$launchArgs=""
    )
    Begin
    {
    #$DebugPreference = 'Continue'
    Write-Debug ("$vmName $vmIP $submaskCidrBits $switchName $switchIp")

    If ( ! (TestSameNetwork -ip1 $vmIp  -ip2 $switchIp -submaskCidrBits $submaskCidrBits))
    {
        Write-Error "La VM et le Switch ne sont pas dans le même sous-réseau."
        Write-Error "$vmIP $switchIp"
        Return
    }

    $tempNetplanFile="99-multipass.yaml"
    $vmTemp="/tmp/99-multipass.yaml"
    $vmNetplanFile="/etc/netplan/99-multipass.yaml"
    # Si nécessaire,
    #    Création d'in switch virtuel de type Internal
    #    Avec son adresse IP
    #    Récupération du numéro d'interface
    If ( ! ( Get-VMSwitch | Where-Object {$_.Name -eq $switchName} ) ) {
        New-VMSwitch -SwitchName $switchName -SwitchType Internal
        $netadapter=Get-NetAdapter | Where-Object Name -Like "*multipass*"
        New-NetIPAddress -PrefixLength $submaskCidrBits -InterfaceIndex $netadapter.ifIndex -IPAddress $switchIp
        #Get-NetIPAddress | Where-Object InterfaceIndex -eq $netadapter.ifIndex
    }

    If ( Get-VM  | Where-Object { $_.Name -eq $vmName } ) {
        Write-Error "La VM $vmName existe déjà."
        Return
    }


    # Lancement de la machine virtuelle
    $multipass="multipass launch --name $vmName --network name=$switchName,mode=manual $launchArgs".Trim()
    Write-Host ($multipass)
    Invoke-Expression $multipass

    if(! $?) {
      Write-Host "ÉCHEC multipass launch"
      Return
    }


    # Récupération de la carte réseau
    $eth1 =  Get-VM | Where-Object Name -Like $vmName | Get-VMNetworkAdapter | Where-Object SwitchName -Like $switchName

    # Récupération de l'adresse mac (hexadécimal et mise en forme avec ':')
    $mac0 = $eth1.MacAddress
    if($mac0.Length -ne 12) {
        Write-Error "L’adresse mac $mac0 a une longueur autre que 12."
        Return
    }
    $mac=$mac0.Insert(10,":").Insert(8,":").Insert("6",":").Insert(4,":").Insert(2,":")
    $mac

    # Création du fichier netplan sur la machine hôte
    if (Test-Path "$tempNetplanFile") {
        Remove-Item "$tempNetplanFile"
    }
    Add-Content "$tempNetplanFile" "network:"
    Add-Content "$tempNetplanFile" "    ethernets:"
    Add-Content "$tempNetplanFile" "        eth1:"
    Add-Content "$tempNetplanFile" "            dhcp4: false"
    Add-Content "$tempNetplanFile" "            match:"
    Add-Content "$tempNetplanFile" "                macaddress: $mac"
    Add-Content "$tempNetplanFile" "            set-name: eth1"
    Add-Content "$tempNetplanFile" "            addresses: [$vmip/$submaskCidrBits]"
    Add-Content "$tempNetplanFile" "    version: 2"

    # Vérification
    Get-Content "$tempNetplanFile"


    # Copie du fichier
    # paramètres "destination" de multipass transfer
    $dest=$vmTemp.Insert(0,":").Insert(0,$vmName)
    # tansfer du fichier de la machine hôte vers la vm dans /tmp
    # pas de transfer direct possible à cause des droits root nécessaires
    multipass transfer "$tempNetplanFile" $dest
    # copy du fichier de /tmp vers /etc/netplan en sudo
    multipass exec $vmName sudo mv $vmTemp $vmNetplanFile
    # suppression du fichier sur la machine hôte
    Remove-Item "$tempNetplanFile"

    # Application des paramètres
    multipass exec $vmName -- sh -c "sudo netplan --debug generate"
    multipass exec $vmName sudo netplan try
    multipass exec $vmName sudo netplan apply
    }
}

#Export-ModuleMember -Function New-MultipassVMIPFixe
