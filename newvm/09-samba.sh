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


# mkdir -p $LOCAL_SHAORE
# sudo chmod 777 $LOCAL_SHAORE
# sudo chown 1000:1000 $LOCAL_SHAORE
# echo "$WINDOWS_SHARE $LOCAL_SHAORE cifs vers=3.0,credentials=/root/.smbcredentials,nounix,uid=1000,gid=1000,nounix,iocharset=utf8,dir_mode=02750,file_mode=0750,forceuid,forcegid,dom=WORKGROUP,mfsymlinks,cache=none,actimeo=0,closetimeo=0 0 0" >> /etc/fstab


#cache=strict cache=loose