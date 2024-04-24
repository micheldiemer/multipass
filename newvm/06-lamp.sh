#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt -y install apache2 mariadb-server

## /var/www
# Ajout de l'utilisateur ubuntu au groupe www-data
sudo usermod -a -G www-data ubuntu
# Changement de propriétaire du dossier /var/www
sudo chown -R ubuntu:www-data /var/www
# Tous les fichiers créés dans /var/www appartiendront au groupe www-data
sudo chmod -R g+s /var/www/
# Les autres n'ont aucun droit sur /var/www
sudo chmod -R o-rwx /var/www/
echo "<?php phpinfo(); " | sudo tee /var/www/html/info.php
rm /var/www/html/index.html

# apache hostname
echo "export HOSTNAME=\$(hostname).mshome.net" >> /etc/apache2/envvars
echo "ServerName \${HOSTNAME}" > /etc/apache2/conf-available/hostname.conf
chmod 644 /etc/apache2/conf-available/hostname.conf
a2enconf hostname

# php 8.3
apt -y install php8.3 php8.3-bcmath php8.3-cli php8.3-curl php8.3-gd php8.3-intl php8.3-mbstring php8.3-mysql php8.3-opcache php8.3-xml php8.3-zip

# apache php8.3
apt -y install libapache2-mod-php8.3 php8.3-fpm
a2enmod setenvif rewrite actions fcgid alias proxy proxy_fcgi
a2enconf php8.3-fpm

# php.ini
ln -s /etc/php/99-php.ini /etc/php/8.3/apache2/conf.d/99-php.ini
#ln -s /etc/php/99-php.ini /etc/php/8.3/cli/conf.d/99-php.ini
ln -s /etc/php/99-php.ini /etc/php/8.3/fpm/conf.d/99-php.ini
systemctl restart php8.3-fpm
systemctl restart apache2


# composer
apt -y install p7zip p7zip-full p7zip-rar zip unzip
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
