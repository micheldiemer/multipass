#!/bin/bash
chmod ugo+r /etc/mysql/mariadb.conf.d/80-dev.cnf
echo "CREATE USER IF NOT EXISTS operations@localhost IDENTIFIED BY 'operations';" | sudo mysql
echo "GRANT ALL PRIVILEGES ON *.* TO 'operations'@'localhost' WITH GRANT OPTION;" | sudo mysql
echo "ALTER USER 'root'@'localhost' IDENTIFIED  BY '';" | sudo mysql
service mysql restart
echo "FLUSH PRIVILEGES;" | sudo mysql