IF NOT EXIST "%~dp0.smbcredentials" (
   echo Fichier .smbcredentials manquant
   exit
)

multipass  transfer "%~dp0.smbcredentials" dev:/home/ubuntu/.smbcredentials
multipass transfer "%~dp0smb.ini" dev:/home/ubuntu/smb.conf

multipass transfer "%~dp009-samba.sh" dev:/tmp/x.sh
multipass transfer "%~dp0samba-fstab.sh" dev:/home/ubuntu
multipass exec dev sudo chmod 777 /tmp/x.sh
multipass exec dev sudo /tmp/x.sh
multipass exec dev sudo rm /tmp/x.sh
