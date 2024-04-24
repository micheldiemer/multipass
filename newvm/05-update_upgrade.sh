#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
locale-gen C.UTF-8
apt install -y software-properties-common ca-certificates apt-transport-https
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
LC_ALL=C.UTF-8 add-apt-repository -y  ppa:ondrej/apache2
apt -y update
apt -y upgrade
