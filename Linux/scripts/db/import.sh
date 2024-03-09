#!/bin/bash

echo "Username:"
read username

echo "Password:"
read -s pass

DUMP_DIR="/root/backups/sql"

if mysql -u $username -p$pass < "$DUMP_DIR/all_databases.sql"; then
    echo "Import successful!"
else
    echo "Error: Import failed."
fi
