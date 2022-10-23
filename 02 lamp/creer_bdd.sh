#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

$MYSQL_DATABASE=db
$MYSQL_DB_USER=db_user
$MYSQL_DB_PASS=Kkaap4jeOnuG
echo "CREATE DATABASE $MYSQL_DATABASE COLLATE 'utf8mb4_unicode_ci';" | mysql
echo "CREATE USER $MYSQL_DATABASE@'localhost' IDENTIFIED BY $MYSQL_DB_PASS;" | mysql
echo "GRANT ALL PRIVILEGES ON $MYSQL_DB_USER.\* TO $MYSQL_DATABASE@'localhost';" | mysql
echo "FLUSH PRIVILEGES;" | mysql