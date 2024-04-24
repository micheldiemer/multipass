multipass transfer "%~dp0mysqld.ini" dev:/tmp/80-dev.cnf
multipass exec dev sudo mv /tmp/80-dev.cnf /etc/mysql/mariadb.conf.d/80-dev.cnf
multipass exec dev sudo chown root:root /etc/mysql/mariadb.conf.d/80-dev.cnf
multipass exec dev sudo chmod 644 /etc/mysql/mariadb.conf.d/80-dev.cnf
multipass transfer "%~dp007-mysql.sh" dev:/tmp/x.sh
multipass exec dev sudo chmod 770 /tmp/x.sh
multipass exec dev sudo /tmp/x.sh
multipass exec dev sudo rm /tmp/x.sh
