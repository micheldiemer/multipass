# Multipass

## Présentation

- Permet d'avoir une machine virtuelle Ubuntu facilement
- Les commandes et configurations de base sont identiques sous Windows/MacOs/Linux

## Pré-requis

- Windows :
  - VirtualBox (possible mais déconseillé)
  - _Recommandé_ : Windows version Pro (acheter une licence à quelques euros) pour pouvoir utiliser HyperV
- Linux
  - snap (pré-installé avec les versions récentes d’ubuntu)
- MacOs : aucun

## Installation

Suivre les instructions depuis [la page de téléchargement/d’installation de multipass](https://multipass.run/install)

## Raccourci vers l’instance primaire

`Ctrl+Alt+U` : démarre (créé si nécessaire) une machine virtuelle qui s'appelle `primary`  
Voir ce raccourci : `multipass get client.gui.hotkey`  
Supprimer ce raccourci : `multipass set client.gui.hotkey=""`

## Commandes multipass

- `multipass list` : liste les machines
- `multipass start <nom>` : démarre une machine
- `multipass stop <nom>` : arrête une machine
- `multipass shell <nom>` : lance un shell dans la machine
- `multipass info <nom>` : affiche des informations détaillées
- `multipass mount <chemin_source> <nom>:<chemin_destination>` : effectue un point de montage
- `multipass delete <nom>` : affiche des informations détaillées
- `multipass purge` : supprimer définitivement une VM
- `multipass launch --name <nom>`  : créer une VM
- `multipass launch --name <nom> --cloud-init <FICHIER>`  : créer une VM avec fichier de configuration cloud-init

## Exemple : création / lancement / arrêt et suppression d'une machine virtuelle

1. `multipass launch --name test --disk 20G`
2. `multipass list`
3. `multipass start test`
4. `multipass shell test`
5. `exit`
6. `multipass stop test`
7. `multipass delete test`
8. `multipass purge`

## Création de la machine virtuelle et lancement

1. `multipass launch --name dev --disk 20G`
2. `multipass list`
3. `multipass shell dev`

## Partage de fichiers

Utiliser `sftp` de préférence
Autres solutions possibles **à éviter** : `multipass mount` ; `samba`

## Créer un utilisateur pour se connecter en ssh

Sur la machine virtuelle (après multipass shell) :

```bash
  # Créer l'utilisateur
  sudo adduser prenom
  # Se connecter
  sudo su prenom
  # Générer les clés publiques/privées
  ssh-keygen -t rsa -m PEM
  cd ~/.ssh
  # Autoriser la connexion avec les nouvelles clés
  cp id_rsa.pub authorized_keys
  # Copier le contenu de la clé
  sudo cat ~/.ssh/id_rsa
```

Sur la machine hôte Windows :

```powershell
# Créé le dossier .ssh si nécessaire
if (-Not (Test-Path "$env:USERPROFILE\.ssh")) { New-Item "$env:USERPROFILE\.ssh" }
# Placer le contenu du presse-papier dans le fichier
Get-Clipboard | Out-File "$env:USERPROFILE\.ssh\id_rsa_dev_prenom.pem" -Encoding ASCII
# Vérifier que cela fonctionne
ssh -o IdentitiesOnly=yes prenom@dev.mshome.net -i "$env:USERPROFILE\.ssh\id_rsa_dev_prenom.pem"
```

## Se connecter en sftp avec VSCode

- Installer l'extension SFTP pour VSCode (Natizyskunk est plus récente et mise à jour par rapport à liximomo)

- Dans la palette de commandes (Ctrl Shift P), saisir `SFTP: Config`

- Configuration sftp.json. Remplacer `\` par `/` dans le chemin de `privateKeyPath`

```json
{
  "name": "dev",
  "host": "dev.local",
  "protocol": "sftp",
  "port": 22,
  "username": "ubuntu",
  "remotePath": "/var/www/html",
  "uploadOnSave": true,
  "useTempFile": false,
  "privateKeyPath": "C:/Users/user/host_user.pem"
}
```

- Dans la palette de commandes (Ctrl Shift P), voir et tester les commandes disponibles : `SFTP:`

## Annexe : Windows/HyperV : réinitialiser le réseau multipass en cas de blocage

- Supprimer le fichier C:\Windows\System32\drivers\etc\hosts.ics
- Get-HNSNetwork | ? Name -Like "Default Switch" | Remove-HNSNetwork
- Restart-Computer
- cf. [https://techsparx.com/linux/multipass/windows/troubleshoot.html]

Voici les commandes `windows powershell en mode administrateur` :

```powershell
#Requires -RunAsAdministrator
if ( Test-Path -Path 'C:\Windows\System32\drivers\etc\hosts.ics' -PathType Leaf )
{
    Remove-Item 'C:\Windows\System32\drivers\etc\hosts.ics'
}
Get-HNSNetwork | Where-Object Name -Like "Default Switch" |      Remove-HNSNetwork
Restart-Computer
```

- Dans la palette de commandes (Ctrl Shift P), voir et tester les commandes disponibles : `SFTP:`

## Annexe : Windows : Augmenter la taille de la machine Virtuelle

Resize-VHD is the way to do it on Windows. You can also use Hyper-V Manager, right click on the instance you are interested in, select Settings..., then select the Hard Drive under IDE Controller 0. From there, you can see the path to the virtual disk. You can also click Edit under the Virtual hard disk and that will bring up the Edit Virtual Hard Disk Wizard. Click Next from here and you will be presented with several different options. Choose Expand -> Next and then fill out whatever size you want to make the disk. Click Next, review the change, and then click Finish.

[https://docs.microsoft.com/en-us/powershell/module/hyper-v/resize-vhd?view=windowsserver2022-ps&viewFallbackFrom=win10-ps]

[https://github.com/canonical/multipass/issues/29]

[Enlarge a virtual machine disk in VirtualBox or VMWare](https://www.howtogeek.com/124622/how-to-enlarge-a-virtual-machines-disk-in-virtualbox-or-vmware/#:~:text=virtualbox%206%20added%20a%20graphical,in%20the%20main%20virtualbox%20window.&text=select%20a%20virtual%20hard%20disk,%e2%80%9d%20when%20you're%20done)

[https://github.com/canonical/multipass/issues/62]

## Annexe : Windows : Se connecter en ssh avec l'utilisateur par défaut (nom d’utilisateur : ubuntu)

La clé de connexion ssh se trouve soit dans le fichier `"%APPDATA%\multipassd\ssh-keys\id_rsa"` soit dans le fichier `C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\ssh-keys\id_rsa@ip`

Il faut éventuellement ajouter un paramètre `-o IdentitiesOnly=yes`

```powershell
ssh -i "%APPDATA%\multipassd\ssh-keys\id_rsa" ubuntu@<host>.local
ssh -i C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\ssh-keys\id_rsa@ip
ssh -o IdentitiesOnly=yes  -i …
```

## Annexe : Se connecter en sftp avec VSCode avec l'utilisateur Ubuntu

- Trouver/installer `openssl` par exemple dans le dossier d'installation de Git ou bien avec `Git Bash`

- Convertir le fichier au format pem :

```powershell
   cd "%APPDATA%\multipassd\ssh-keys"
   ou bien
   cd C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\ssh-keys

   openssl rsa -in id_rsa -outform pem > id_rsa.pem
```

- Sur la machine virtuelle, donner les droits d'accès à l'utilisateur ubuntu : `sudo chmod 777 /var/www/html`

- Installer l'extension SFTP pour VSCode (Natizyskunk est plus récente et mise à jour par rapport à liximomo)

- Dans la palette de commandes (Ctrl Shift P), saisir `SFTP: Config`

- Configuration sftp.json. Remplacer `\` par `/` dans le chemin de `privateKeyPath`

```json
{
  "name": "dev",
  "host": "dev.local",
  "protocol": "sftp",
  "port": 22,
  "username": "ubuntu",
  "remotePath": "/var/www/html",
  "uploadOnSave": true,
  "useTempFile": false,
  "privateKeyPath": "C:/Windows/System32/config/systemprofile/AppData/Roaming/multipassd/ssh-keys/id_rsa.pem"
}
```
