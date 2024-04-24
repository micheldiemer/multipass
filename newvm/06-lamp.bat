multipass transfer "%~dp0php.ini" dev:/tmp/99-php.ini
multipass exec dev sudo chown root:root /tmp/99-php.ini
multipass exec dev sudo chmod 644 /tmp/99-php.ini
multipass exec dev sudo mv /tmp/99-php.ini /etc/php/99-php.ini

multipass transfer "%~dp006-lamp.sh" dev:/tmp/x.sh
multipass exec dev sudo chmod 770 /tmp/x.sh
multipass exec dev sudo /tmp/x.sh