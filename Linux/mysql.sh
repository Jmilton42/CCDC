#!/bin/bash

echo "Username:"
read username

echo "Password:"
read -s pass

pkg=$(which apt || which yum || which pacman || which apk || which zypper || which dnf)

if [ -z "$(dpkg -l | grep mysql)" ]; then
	echo "MySQL is not installed, installing it now."

	if [[ -z "$pkg" ]]; then
	    echo "[-] Could not find a package manager. Run pspy manually"
	fi
	
	case $pkg in
	    *apt*)
	        apt install -y mysql-server
	        ;;
	    *yum*)
	        yum install -y mysql-server
	        ;;
	    *pacman*)
	        pacman -S --noconfirm mariadb
	        ;;
	    *apk*)
	        apk add mariadb-server
	        ;;
	    *zypper*)
	        zypper install -y mariadb
	        ;;
	    *dnf*)
	        dnf install -y mariadb-server
	        ;;
	    *)
	        echo "[-] Could not find a package manager. Run pspy manually"
	        ;;
	esac
	
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

	case $pkg in
	    *apt*)
	        apt install -y mysql-workbench
	        ;;
	    *yum*)
	        yum install -y mysql-workbench
	        ;;
	    *pacman*)
	        pacman -S --noconfirm mysql-workbench
	        ;;
	    *apk*)
	        apk add mysql-workbench
	        ;;
	    *zypper*)
	        zypper install -y mysql-workbench
	        ;;
	    *dnf*)
	        dnf install -y mysql-workbench
	        ;;
	    *)
	        echo "[-] Could not find a package manager. Run pspy manually"
        ;;
	esac

fi
