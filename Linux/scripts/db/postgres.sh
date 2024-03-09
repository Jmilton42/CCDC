#!/bin/bash

read -p "Enter the root password for PostgreSQL: " root_password
read -p "Enter the normal password for PostgreSQL: " normal_password

# get list of all postgres users
users=$(sudo -u postgres psql -t -c "SELECT usename FROM pg_user;")

# change password for each user
for user in $users; do
    if [ "$user" == "postgres" ]; then
        sudo -u postgres psql -c "ALTER USER $user WITH ENCRYPTED PASSWORD '$root_password';"
    elif [ "$user" == "seccdc_black" ]; then
        continue
    else
        sudo -u postgres psql -c "ALTER USER $user WITH ENCRYPTED PASSWORD '$normal_password';"
    fi
done

echo "All PostgreSQL passwords have been changed."

# remove history file so passwords cannot be recovered
# unless we go sicko forensic mode
rm ~/.psql_history
