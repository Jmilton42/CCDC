#!/bin/bash

echo "Username:"
read username

echo "Password:"
read pass

if [ -z "$(dpkg -l | grep mysql)" ]; then
	echo "MySQL is not installed, installing it now."
	sudo apt update 
	sudo apt install -y mysql-server
else
	version=$(mysql --version | awk '{print $5}') 
	echo "MySQL is already installed, the version is $version."
fi

DUMP_DIR="/root/backups/sql"

mkdir -p "$DUMP_DIR"

echo "dumping all databases"

mysqldump -u $username -p$pass --all-databases > "$DUMP_DIR/all_databases.sql"

echo "Would you like to install MySQL Workbench?"
read choice

if [ "$choice" == "yes" ]; then
	sudo apt update
	sudo apt install mysql-workbench
fi
