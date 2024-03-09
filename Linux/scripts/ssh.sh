#!/bin/bash

sed -i -E 's/(#PubkeyAuthentication yes|PubkeyAuthentication yes)/PubkeyAuthentication no/g' /etc/ssh/sshd_config
sed -i -E 's/(#PubkeyAuthentication yes|PubkeyAuthentication yes)/PubkeyAuthentication no/g' /etc/ssh/ssh_config

# Go through each home directory and rename the .ssh directory to .ssh.bak
for user in $(ls /home); do
    if [ -d /home/$user/.ssh ]; then
        mv /home/$user/.ssh /home/$user/.ssh.bak
    fi
done

service ssh restart || service sshd restart || systemctl restart ssh || systemctl restart sshd || /etc/rc.d/ssh restart || /etc/rc.d/sshd restart || echo "[-] Could not restart SSH service"
