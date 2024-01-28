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
    if id -nG "$1" | grep -qwv "$2"; then
        # Check if group exists
        if getent group $2 | grep -qw $2; then
            pw groupmod $2 -m $1
            log "Added user $1 to group $2"
        fi
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
    echo "$2" | pw mod user $1 -h 0 2>/dev/null
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
for u in $(getent passwd | cut -d: -f1); do
    # Get username, UID, and login shell from /etc/passwd
    username=$(getent passwd $u | cut -d: -f1)
    uid=$(getent passwd $u | cut -d: -f3)
    shell=$(getent passwd $u | cut -d: -f7)

    # Check if user is root or shell does not match ^/bin/.*sh$
    if echo "$username" | grep -q "^root$" || ! echo "$shell" | grep -q "^/bin/.*sh$"; then
        continue
    fi

    # Check if user is in passwords.csv 
    if grep -qw "$username" "passwords.csv"; then
        # Get password and group from passwords.csv
        password=$(grep "$username" "passwords.csv" | cut -d, -f2)
        admin=$(grep "$username" "passwords.csv" | cut -d, -f3)
        
        set_user_password "$username" "$password" "$uid"
        # Add or remove the user from admin groups as necessary
        for group in adm admin lpadmin sambashare sudo wheel; do
            if echo "$admin" | grep -q "admin"; then
                add_user_to_group $username $group
            else
                remove_user_from_group $username $group
            fi
        done
    else
        # Lock user account and remove from all groups
        pw lock $username
        log "Found user $username with UID $uid and locked account"
        for group in adm admin lpadmin sambashare sudo wheel; do
            remove_user_from_group $username $group
        done
    fi
done