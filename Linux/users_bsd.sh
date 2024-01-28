#!/bin/sh

# Log file location
log_file="/root/log/users_$(date +%Y%m%d_%H%M%S).log"

# Create log directory if it does not exist
mkdir -p /root/log

# Log message function to log to console and file
log() {
    echo "$1"
    echo "$(date): $1" >> $log_file
}

# Function to check if a file exists and is not empty
check_file() {
    if [ ! -f $1 ]; then
        echo "Error: $1 does not exist"
        exit 1
    fi
    if [ ! -s $1 ]; then
        echo "Error: $1 is empty"
        exit 1
    fi
}

# Function to check if a CSV file has a certain number of fields
check_csv_fields() {
    if [ $(awk -F, '{print NF}' $1 | sort -nu | tail -n 1) -ne $2 ]; then
        echo "Error: $1 does not have $2 fields on every line"
        exit 1
    fi
}

# Function to add a user to a group
add_user_to_group() {
    if id -nG "$1" | grep -qw "$2"; then
        pw groupmod $2 -m $1
        log "Added user $1 to group $2"
    fi
}

# Function to remove a user from a group
remove_user_from_group() {
    if id -nG "$1" | grep -qw "$2"; then
        pw groupmod $2 -d $1
        log "Removed user $1 from group $2"
    fi
}

# Function to set the user's password and shell
set_user_password() {
    echo "$1:$2" | chpass
    log "Found user $1 with UID $3 and changed password"
}

# Check if necessary files exist and are not empty
check_file "/root/backup/passwd"
check_file "/root/backup/master.passwd"
check_file "/root/backup/group"
check_file "passwords.csv"

# Check if passwords.csv has 3 fields
check_csv_fields "passwords.csv" 3

# Loop through every user in /etc/passwd 
for u in $(dscl . -list /Users | grep -v '^_'); do
    # Get username, UID, and login shell from /etc/passwd
    username=$(id -un $u)
    uid=$(id -u $u)
    shell=$(dscl . -read /Users/$u UserShell | awk '{print $2}')

    # Skip if the user is root or does not have a valid login shell
    if [ "$username" == "root" ] || [[ ! "$shell" =~ ^/bin/.*sh$ ]]; then
        continue
    fi

    # Check if the user is in passwords.csv
    if grep -q "^$username," passwords.csv; then
        # Get password and admin status from passwords.csv
        password=$(grep "^$username," passwords.csv | cut -d, -f2 | tr -d '\r')
        admin=$(grep "^$username," passwords.csv | cut -d, -f3 | tr -d '\r')

        # Set the user's password and shell
        set_user_password $username $password $uid

        # Add or remove the user from admin groups as necessary
        for group in adm admin lpadmin sambashare sudo wheel; do
            if [ "$admin" == "admin" ]; then
                add_user_to_group $username $group
            else
                remove_user_from_group $username $group
            fi
        done
    else
        # Lock user account and remove from all groups
        passwd -l $username
        log "Found user $username with UID $uid and locked account"
        for group in adm admin lpadmin sambashare sudo wheel; do
            remove_user_from_group $username $group
        done
    fi
done