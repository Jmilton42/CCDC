#!/bin/bash

read -p "Enter the root password for MySQL: " root_password
read -p "Enter the normal password for MySQL: " normal_password

# Get a list of users from MySQL system tables excluding certain users
users=$(mysql -uroot -e "SELECT DISTINCT user, host FROM mysql.user WHERE user NOT IN ('seccdc_black');")

# Loop through each user and generate and execute ALTER USER statement
while read -r user_info; do
    user=$(echo "$user_info" | awk '{print $1}')
    host=$(echo "$user_info" | awk '{print $2}')
    if [ "$user" == "root" ]; then
        mysql -uroot -e "ALTER USER '$user'@'$host' IDENTIFIED WITH mysql_native_password BY '$root_password';"
    else
        mysql -uroot -e "ALTER USER '$user'@'$host' IDENTIFIED BY '$normal_password';"
    fi
done <<< "$users"

# Flush privileges (dont believe this is necessary)
mysql -uroot -e "FLUSH PRIVILEGES;"

echo "All MySQL passwords have been changed."
