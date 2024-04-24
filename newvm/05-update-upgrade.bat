multipass transfer "%~dp005-update_upgrade.sh" dev:/tmp/x.sh
multipass exec dev sudo chmod 770 /tmp/x.sh
multipass exec dev sudo /tmp/x.sh