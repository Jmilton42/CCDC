#!/bin/sh

backup_folder="/root/backup"
mkdir -p "$backup_folder"
cp /etc/master.passwd "$backup_folder"
cp /etc/passwd "$backup_folder"
cp /etc/group "$backup_folder"
cp /etc/ssh/ssh_config "$backup_folder"
