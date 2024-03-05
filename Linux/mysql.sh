#!/bin/bash

echo "Username:"
read username

echo "Password:"
read -s pass

pkg=$(which apt || which yum || which pacman || which apk || which zypper || which dnf)

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
