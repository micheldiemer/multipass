#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt -y install cifs-utils samba
apt -y install linux-generic linux-modules-extra-$(uname -r)

mv /home/ubuntu/.smbcredentials /root/.smbcredentials
chown root:root /root/.smbcredentials
chmod 660 /root/.smbcredentials

echo "" >> /etc/samba/smb.conf
cat /home/ubuntu/smb.conf >> /etc/samba/smb.conf
rm /home/ubuntu/smb.conf

mkdir -p /var/www/skillandyou
sudo chmod 777 /var/www/skillandyou
echo "//PC-MICHELD.mshome.net/skillandyou /var/www/skillandyou cifs vers=3.0,credentials=/root/.smbcredentials,uid=1000,gid=33,nounix,iocharset=utf8,dir_mode=02750,file_mode=0750,forceuid,forcegid,dom=WORKGROUP,mfsymlinks,cache=none,actimeo=0,closetimeo=0 0 0" >> /etc/fstab

mkdir -p /var/www/mutillidae
sudo chmod 777
echo "//PC-MICHELD.mshome.net/mutillidae /var/www/mutillidae  cifs vers=3.0,credentials=/root/.smbcredentials,nounix,uid=1000,gid=33,nounix,iocharset=utf8,dir_mode=02750,file_mode=0750,forceuid,forcegid,dom=WORKGROUP,mfsymlinks,cache=none,actimeo=0,closetimeo=0 0 0" >> /etc/fstab

mkdir -p /home/ubuntu/bin
sudo chmod 777 /home/ubuntu/bin
echo "//PC-MICHELD.mshome.net/multipass-bin /home/ubuntu/bin cifs vers=3.0,credentials=/root/.smbcredentials,nounix,uid=1000,gid=1000,nounix,iocharset=utf8,dir_mode=02750,file_mode=0750,forceuid,forcegid,dom=WORKGROUP,mfsymlinks,cache=none,actimeo=0,closetimeo=0 0 0" >> /etc/fstab

/home/ubuntu/bin/new_vhost.sh skillandyou
/home/ubuntu/bin/new_vhost.sh mutillidae

mount -a
#cache=strict cache=loose