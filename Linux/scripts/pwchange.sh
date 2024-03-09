#!/bin/bash

password1="password1"
password2="password2"

# Get all users with /bin/*sh as their shell
users=$(cat /etc/passwd | grep -vE '(false|nologin|sync)$' | grep -E '/.*sh$' | cut -d':' -f1)

# Change all passwords to password1
for user in $users; do

    # Skip seccdc_black and ttuccdc users
    if [ "$user" == "seccdc_black" ] || [ "$user" == "ttuccdc" ]; then
        continue
    fi

    echo "Changing password for $user to $password1"
    (echo -e "$password1\n$password1" | passwd $user) || (echo -e "$user:$password1" | chpasswd)
done

# Check if ttuccdc user exists
# If it does, change the password to password2
# If it doesn't, create the user with password2 and add it to the sudo group
if id ttuccdc &>/dev/null; then
    echo "Changing ttuccdc password to $password2"
    (echo -e "$password2\n$password2" | passwd ttuccdc) || (echo -e "ttuccdc:$password2" | chpasswd)
else
    echo "Creating ttuccdc user with password $password2"
    useradd -m ttuccdc || pw useradd -n ttuccdc -m
    (echo -e "$password2\n$password2" | passwd ttuccdc) || (echo -e "ttuccdc:$password2" | chpasswd)
    usermod -s /bin/bash ttuccdc || echo "Could not set ttuccdc shell to /bin/bash"
    usermod -aG sudo ttuccdc || pw groupmod wheel -m ttuccdc
fi
