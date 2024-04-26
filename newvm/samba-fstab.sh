#!/bin/bash
SRV_SHARE=$1
LOCAL_MOUNT=$2
CREDENTIALS=/root/.smbcredentials

sudo bash -c "test -f $CREDENTIALS"
if [ $? -ne 0 ]
then
    echo "Fichier manquant : " . $CREDENTIALS
    exit 1
fi
if [ -z "$2" ]; then
    echo "Usage: $0 <SRV_SHARE> <LOCAL_MOUNT> <USER>(ubuntu) <GROUP>(www-data) <DOMAIN>(WORKGROUP)"
    exit 1
fi
if [ -z "$3" ]; then
    SMBUID=$(id -u ubuntu)
else
  [ ! -z "${num##*[!0-9]*}" ] && SMBUID=$3|| SMBUID=$(id -u $3);
fi
if [ -z "$4" ]; then
    SMBGID=$(id -u www-data)
else
  [ ! -z "${num##*[!0-9]*}" ] && SMBGID=$4|| SMBGID=$(id -u $4);
fi
[ -z $5 ] && DOMAIN=WORKGROUP || DOMAIN=$5

sudo mkdir -p $LOCAL_MOUNT
sudo chmod 777 $LOCAL_MOUNT
sudo chown $SMBUID:$SMBGID $LOCAL_MOUNT
echo "$SRV_SHARE $LOCAL_MOUNT cifs vers=3.0,credentials=$CREDENTIALS,uid=$SMBUID,gid=$SMBGID,nounix,iocharset=utf8,dir_mode=02750,file_mode=0750,forceuid,forcegid,domain=$DOMAIN,mfsymlinks,actimeo=0,closetimeo=0 0 0" | sudo tee -a /etc/fstab


sudo mount -a
sudo systemctl daemon-reload
