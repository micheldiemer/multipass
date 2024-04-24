multipass transfer "%~dp004-locale-fr.sh" dev:/tmp/x.sh
multipass exec dev sudo chmod 770 /tmp/x.sh
multipass exec dev sudo /tmp/x.sh
