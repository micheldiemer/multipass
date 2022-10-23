# Installer LAMP / LINUX APACHE MYSQL PHP

Toutes les commandes sont à exécuter via Git Bash

## Réglages initiaux

```bash
MACHINE=dev
USERNAME=user
USER_GIT_EMAIL=test@dev.local
PHP_VERSION=8.1

MYSQL_USER=mariadb
MYSQL_PASSWORD=elknYIYtQ9LE
MYSQL_DATABASE=db
```

## Créer la machine

```bash
multipass launch --name $MACHINE --disk 20G`
# ou avec cloud-init
# FICHIER=lamp.yaml
# multipass launch --name $MACHINE --cloud-init $FICHIER
```

## Suite

- Se connecter à la VM

  ```bash
  multipass shell $MACHINE
  ```

- Devenir `root`

  ```bash
  sudo su
  ```

- Effectuer les mises à jour

  ```bash
  apt update --yes && apt upgrade --yes
  ```

- Installer quelques paquets

  ```bash
  apt install zip unzip mariadb-server git --yes
  ```

- Choisir et installer une version de PHP

  - Valider les interfaces graphiques

  - Valider les mots de passe, etc.

  - si nécessaire ajouter des sources pour trouver la bonne version de PHP

    ```bash
    # étape facultative
    add-apt-repository ppa:ondrej/php
    add-apt-repository ppa:ondrej/apache2
    ```

  - php7.4 avec les modules

    ```bash
    # choisir php7.4 ou bien php8
    apt install apache2 php7.4 libapache2-mod-fcgid libapache2-mod-php7.4 php7.4-mysql php7.4-bcmath php7.4-xml php7.4-fpm php7.4-zip php7.4-intl php7.4-gd php7.4-cli php7.4-mbstring php7.4-opcache php7.4-xdebug -y
    apt install phpmyadmin --yes
    ```

  - php8.1 avec les modules

    ```bash
    # choisir php7.4 ou bien php8
    apt install apache2 php8.1 libapache2-mod-php8.1 libapache2-mod-fcgid php8.1-mysql php8.1-bcmath php8.1-xml php8.1-fpm php8.1-zip php8.1-intl php8.1-gd php8.1-cli php8.1-mbstring php8.1-opcache php8.1-xdebug -y
    # vérifier si phpmyadmin fonctionne
    apt install phpmyadmin --yes
    ```

  - Installer composer

    ```bash
    nano ./install_composer.sh
    # copier-coller le contenu de composer.sh
    ./install_composer.sh
    ```

  - pour configurer phpmyadmin

    ```bash
    ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
    a2enconf phpmyadmin
    systemctl reload apache2
    ```

  - pour installer le module `mcrypt`

    ```bash
    apt install -y build-essential php-pear php-dev libmcrypt-dev
    pecl channel-update pecl.php.net && pecl update-channels && pecl install mcrypt
    cd /etc/php/\*/mods-available/
    echo "extension=mcrypt.so" > mcrypt.ini
    ```

- Une configuration pour git

  ```bash
  git config --global core.eol lf
  #git config --system core.autocrlf true
  ```

- Créer un utilisateur pour la BDD

  ```bash
  echo "CREATE USER $MYSQL_USER@'localhost' IDENTIFIED BY \'$MYSQL_PASSWORD\';" | mysql
  echo "GRANT ALL PRIVILEGES ON*.\_ TO $MYSQL_USER@'localhost' WITH GRANT OPTION;" | mysql
  echo "FLUSH PRIVILEGES;" | mysql
  ```

- Configurer le `hostname`pour apache2, tester et vérifier

  - Créer le fichier de configuration

    ```bash
    $HCONF=/etc/apache2/conf-available/hostname.conf
    source /etc/apache2/envvars
    echo "ServerName ${HOSTNAME}.local" > $HCONF
    echo "ServerAlias www.${HOSTNAME}.local" >> $HCONF
    echo "ServerAlias ${HOSTNAME}" >> $HCONF
    echo "ServerAlias ${HOSTNAME}.mshome.net" >> $HCONF
    echo "ServerAlias www.${HOSTNAME}.mshome.net" >> $HCONF
    ```

  - Gérer les permissions sur le dossiers `/var/www`

    ```bash
    # Le dossier appartient à www-data
    #    utilisateur par défaut de Apache
    chown -R www-data:www-data /var/www
    # Permettre à toute personne dans le groupe
    #    www-data de modifier les fichiers
    chmod -R g+w /var/www
    # Tous les fichiers créés dans www-data
    #    doivent appartenir au groupe www-data
    chmod -R g+s /var/www /var/www/html
    # Ajouter l'utilisateur ubuntu dans www-data
    #    pour qu'il puisse avoir le droit
    #    de modifer les fichiers
    usermod -a -G www-data ubuntu
    ```

  - Activer les configurations

    ```bash
    # Activer hostname.com
    a2enconf hostname
    # Activer des modules apache2
    a2enmod proxy_fcgi setenvif
    # Activier php fmp pour que ça soit plus rapide
    a2enconf php$PHP_VERSION-fpm
    # Relancer apache2
    systemctl reload apache2
    # Relancer apache2
    systemctl reload php$PHP_VERSION-fpm
    # Vérifier la configuratio d'apacte2
    apache2 -t
    ```

- Créer un User a votre nom

  - Créer le User

  ```bash
  adduser $USERNAME
  ```

  - L'ajouter au groupe www-data

  ```bash
  sudo usermod -a -G www-data $USERNAME
  ```

  - Option : l'ajouter au sudoers

  ```bash
  sudo usermod -a -G sudo $USERNAME
  ```

  - Se connecter avec cet utilisateur

  ```bash
  su -l $USERNAME
  ```

  - Paramétrer Git avec votre email et nom d'utilisareur

  ```bash
  git config --global user.name $USER
  git config --global user.email $USER_GIT_EMAIL
  ```

  - Créer une clé SSH à mettre dans Git

    **Nom du fichier :** `~/.ssh/id_rsa_git`

    ```bash
    # Création de la clé SSH
    ssh-keygen -t rsa -b 4096
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa_git
    echo Il faut aller sur Git et ajouter la clé SSH
    # Verifier si SSH via HTTPS fonctionne
    ssh -T -p 443 git@ssh.github.com
    ```

  - Créer une clé SSH pour la connexion SFTP

    **cf. `multipass.md`** pour ce point

## Compléments

1. Créer une base de données cf. `./creer_bdd.sh`
2. Mettre Ubuntu en français cf. `./ubuntu_fr.sh`
