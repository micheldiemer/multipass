# Lamp avec multipass

## Pré-requis

- multipass installé
- Windows : Windows version Professionnel avec Hyper-V correctement configuré et activé
- Sur Windows, le driver est `hyperv`. Recréez vos machines virtuelles virtualbox si nécessaire.

```powershell
# Utilisation de Hyper-V pour multipass
multipass set local.driver=hyperv
```

## Création de la machine virtuelle

Sur Windows Powershell :

```pwsh
$VMNAME="lamp"
$DISK_SIZE="20G"
$VERSION="lts"
```

<div class="page">

Sur Linux ou MACOS bash :

```bash
VMNAME="lamp"
DISK_SIZE="20G"
VERSION="lts"
```

Création de la machine virtuelle :

```bash
multipass launch --name $VMNAME --disk $DISK_SIZE $VERSION
multipass shell $VMNAME
```

Patientez jusqu'à ce que la machine virtuelle s'installe et se lance

```bash
# Liste des programmes et modules à installer/activer
APACHE="apache2 libapache2-mod-php"
APACHE_MODS="rewrite actions"
PHP_MODS="php php-bcmath php-cli php-curl php-gd php-intl php-mbstring
php-mysql php-pdo php-xml php-zip php-xdebug"
PHP_MODS="php8.2 php8.2-bcmath php8.2-cli php8.2-curl php8.2-gd php8.2-intl php8.2-mbstring php8.2-mysql php8.2-pdo php8.2-xml php8.2-zip php8.2-xdebug"
SGBD=mariadb-server
TOOLS="curl zip unzip"
MAIL="msmtp msmtp-mta"

# Installation des programmes
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install --yes $APACHE $PHP_MODS $SGBD $TOOLS $MAIL
# Activation des modules apache2 et redémarrage de apache2
sudo a2enmod $APACHE_MODS
echo "ServerName \${HOSTNAME}" | sudo tee /etc/apache2/conf-available/hostname.conf
sudo systemctl restart apache2

# Ajustement des droits pour les dossiers apache2
sudo chown -R www-data:www-data /var/www
sudo chmod 2770 /var/www /var/www/html
sudo chmod 0660 /var/www/html/index.html
sudo usermod -a -G www-data ubuntu

# Ajustement des fichiers par défaut
sudo mv /var/www/html/index.html /var/www/html/_index.html
echo "<?php phpinfo();" | sudo tee /var/www/html/phpinfo.php
echo "<?php echo 'Hello, world"'!'"';" | sudo tee /var/www/html/hello.php
echo "<?php echo \$_GET['a'];" | sudo tee /var/www/html/test_erreur.php

# Installation de composer, le gestionnaire de librairies php
# cf. https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md

# EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
# ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Configuration du fichier php.ini par téléchargement
PHPV=$(ls /etc/php | head -n 1)
PHP_CONFD=/etc/php/$PHPV/apache2/conf.d
PHP_INI=$PHP_CONFD/99_php.ini
sudo curl https://gist.githubusercontent.com/micheldiemer/6c6f98d06e749d39697398747d0abe13/raw -o $PHP_INI
sudo systemctl restart apache2
echo Pour tester :
echo "    http://$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)"
echo "  Sous Windows : http://$HOSTNAME.mshome.net"
exit
```

<div class="page">

## Windows : Création d'un utilisateur pour le partage des fichiers

Dans Powershell

Avec certaines versions (7.4) récentes de PowerShell il faut charger un module pour éviter des erreurs :

```powershell
# En tant qu'Administrateur
Import-Module microsoft.powershell.localaccounts -UseWindowsPowerShell
```

Pour le mot de passe, soit on peut le prédéfinir soit demander une saisie :

Création du nouvel utilisateur (une seule fois) :

```powershell
# En tant qu'Administrateur
$USER_NAME="multipass-smb"
$MOT_DE_PASSE_CLAIR="operations123"
$MOT_DE_PASSE=ConvertTo-SecureString -String $MOT_DE_PASSE_CLAIR -AsPlainText -Force
New-LocalUser -Name $USER_NAME -Password $MOT_DE_PASSE
# Add-LocalGroupMember -SID "S-1-5-32-545" -Member "multipass-smb"
# Get-LocalGroup
# [Security.Principal.WindowsIdentity]::GetCurrent()
Add-LocalGroupMember -SID "S-1-5-32-545" -Member $USER_NAME
```

Dans `Stratégie de sécurité locale`, `Stratégiees locales`, `Attribution des droits utilisateurs`, ajouter l'utilisateur à la liste `Interdire l'ouverture d'une session locale`.

Insallation du client `samba` (une seule fois) :

```powershell
multipass exec $VMNAME -- sudo apt install --yes smbclient cifs-utils
```

Création du dossier sous Windows :

```powershell
$PROJET="site1"
$DOSSIER="$env:USERPROFILE\Documents\BTS SIO\Projets Web\$PROJET"
if (!(Test-Path $DOSSIER)) { mkdir $DOSSIER }
#$MOT_DE_PASSE_CLAIR = Read-Host "Veuillez saisir le mot de passe pour le partage de fichiers"
```

Autorisations pour le nouvel utilisateur sur le nouveau dossier :

```powershell
$USER_NAME="multipass-smb"
$MOT_DE_PASSE_CLAIR="operations123"

$acl = Get-Acl $DOSSIER
$acl_new = New-Object System.Security.AccessControl.FileSystemAccessRule( $USER_NAME, "FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($acl_new)
Set-Acl -Path $DOSSIER -AclObject $acl
```

Activation du partage sur la machine virtuelle :

```powershell
$PROJET="site1"

# Récupération des informations : nom de l'ordinateur, du group et partage
$SMB_SERVER_NAME=(((Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Name) + ".mshome.net")
$SMB_DOMAIN=(Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Domain
$CLIENT_FOLDER="/mnt/www/$PROJET"
New-SmbShare -Name $PROJET -Path $DOSSIER -FullAccess $USER_NAME

# Création du dossier dans /mnt
multipass exec $VMNAME -- sudo mkdir -p $CLIENT_FOLDER

# Actvation du partage dans le fichier /etc/fstab
$FSTAB_ADD="//$SMB_SERVER_NAME/$PROJET  $CLIENT_FOLDER cifs username=multipass-smb,domain=$SMB_DOMAIN,uid=33,gid=33,forceuid,forcegid,dir_mode=02750,file_mode=0750,actimeo=0,closetimeo=0,password=$MOT_DE_PASSE_CLAIR 0 0"
multipass exec $VMNAME -- sudo sh -c  ('sudo echo ' + ('"' + $FSTAB_ADD + '"') + ' >> /etc/fstab')
multipass exec $VMNAME -- sudo mount -a
```

<div class="page">

## Ajout d'un VirtualHost

```bash
multipass shell $VMNAME

PROJET="site1"
FQDN="$PROJET.lan"
CLIENT_FOLDER="/var/www/$PROJET"
APACHE_CONF="/etc/apache2/sites-available/$PROJET.conf"
PORT="8081"

# Vérifications
[ ! -d $CLIENT_FOLDER ] && CLIENT_FOLDER=/mnt/www/$PROJET
[ ! -d $CLIENT_FOLDER ] && echo "Dossier $CLIENT_FOLDER manquant." && exit

echo "<h1>$PROJET.lan</h1>" | sudo tee $CLIENT_FOLDER/index.html
nc -z localhost $PORT
test $? -eq 0  && echo Port $PORT occupé && exit
[ -f $APACHE_CONF ] && echo Le fichier $APACHE_CONF existe && exit

# Création du fichier
sudo tee $APACHE_CONF  > /dev/null <<-EOF
Listen $PORT
<VirtualHost *:$PORT $FQDN>
        ServerName $FQDN
        DocumentRoot $CLIENT_FOLDER
        <Directory $CLIENT_FOLDER>
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>
EOF

sudo a2ensite $PROJET
sudo systemctl reload apache2

echo Pour tester :
echo "    http://$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1):$PORT"
echo "  Sous Windows : http://$HOSTNAME.mshome.net:$PORT"
exit
```
