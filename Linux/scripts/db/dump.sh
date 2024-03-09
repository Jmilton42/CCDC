#!/bin/bash

echo "Username:"
read username

echo "Password:"
read -s pass

DUMP_DIR="/root/backups/sql"

mkdir -p "$DUMP_DIR"

echo "dumping all databases"

mysqldump -u $username -p$pass --all-databases > "$DUMP_DIR/all_databases.sql"
