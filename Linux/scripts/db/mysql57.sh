#!/bin/bash

read -p "Enter the root password for MySQL: " root_password
read -p "Enter the normal password for MySQL: " normal_password

mysql -uroot -e "UPDATE mysql.user SET authentication_string = PASSWORD('$normal_password') WHERE user NOT IN ('root','seccdc_black');"
mysql -uroot -e "UPDATE mysql.user SET authentication_string = PASSWORD('$root_password') WHERE user = 'root';"
mysql -uroot -e "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root'";

mysql -uroot -e "FLUSH PRIVILEGES;"

echo "All MySQL passwords have been changed."
