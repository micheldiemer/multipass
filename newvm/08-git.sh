#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt -y install git

git config --global user.email michel.diemer@yahoo.fr
git config --global user.name "Michel Diemer"
git config --global core.eol lf
git config --global core.autocrlf false
git config --global core.ignorecase false
git config --global init.defaultbranch main
git config --global core.excludesfile /home/ubuntu/.gitignore_global

