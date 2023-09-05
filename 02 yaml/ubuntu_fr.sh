#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt-get install language-pack-fr
if [ -f /etc/default/locale ]; then cp /etc/default/locale /etc/default/locale_default; fi
echo "LANG=fr_FR.UTF-8" > /etc/default/locale
cat /etc/default/locale
LANG=fr_FR.UTF-8
dpkg-reconfigure locales