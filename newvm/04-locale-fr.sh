#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt -y install language-pack-fr manpages-fr manpages-fr-dev manpages-fr-extra
sed -i s/^#\ fr_FR.UTF-8/fr_FR.UTF-8/g /etc/locale.gen
locale-gen fr_FR.UTF-8
localectl set-locale LANG=fr_FR.UTF-8