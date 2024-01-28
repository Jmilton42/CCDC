#!/bin/bash

backup_folder="/root/backup"
shadow_file="/etc/shadow"
passwd_file="/etc/passwd"
groups_file="/etc/group"
sshd_config_file="/etc/ssh/ssh_config"
sudoers_file="/etc/sudoers"
sudoers_d_file="/etc/sudoers.d"
nginx_file="/etc/nginx"
apache_file="/etc/apache2"
www_file="/var/www"

# Checks to see if the script needs to be with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi
 
#Checks if the backup folder exists
if [ ! -d "$backup_folder" ]; then
    mkdir "$backup_folder"
fi 

#Backups on the following files
cp "$shadow_file" "$backup_folder"
cp "$passwd_file" "$backup_folder"
cp "$groups_file" "$backup_folder"
cp "$sshd_config_file" "$backup_folder"
cp "$sudoers_file" "$backup_folder"
cp -r "$sudoers_d_file" "$backup_folder"
cp -r "$nginx_file" "$backup_folder"
cp -r "$apache_file" "$backup_folder"
cp -r "$www_file" "$backup_folder"


