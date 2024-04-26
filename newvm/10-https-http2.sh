#!/bin/bash
apt install -y mkcert
mkdir -p $(mkcert -CAROOT)
mv /home/ubuntu/rootCA.pem $(mkcert -CAROOT)/rootCA.pem
mv /home/ubuntu/rootCA-key.pem $(mkcert -CAROOT)/rootCA-key.pem
chown -R root:root $(mkcert -CAROOT)
chmod -R 700 $(mkcert -CAROOT)
mkcert -install

a2enmod ssl socache_shmcb rewrite headers
a2dismod mpm_prefork mpm_worker
a2enmod http2 proxy_http2 mpm_event

mkdir /etc/apache2/ssl
chmod 2770 /etc/apache2/ssl
chown www-data:www-data /etc/apache2/ssl
ln -s $(mkcert -CAROOT)/rootCA.pem /etc/apache2/ssl/rootCA.pem
ln -s $(mkcert -CAROOT)/rootCA-key.pem /etc/apache2/ssl/rootCA-key.pem

sudo systemctl restart apache2


# Protocols h2
# Protocols h2c

# https://ssl-config.mozilla.org/#server=apache&version=2.4.41&config=modern&openssl=1.1.1k&guideline=5.7

# VirtualHost / recommandé
# Redirect permanent / https://example.com/
