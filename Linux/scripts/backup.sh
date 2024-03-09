#!/bin/bash

mkdir -p /root/backups /root/backups/etc /root/backups/var
cp /etc/passwd /root/backups/etc
cp /etc/shadow /root/backups/etc
cp /etc/group /root/backups/etc
cp /etc/sudoers /root/backups/etc
cp /etc/hosts /root/backups/etc
cp /etc/network/interfaces /root/backups/etc
cp /etc/resolv.conf /root/backups/etc
cp /etc/hostname /root/backups/etc
cp -r /etc/sudoers.d/ /root/backups/etc
cp -r /etc/nginx/ /root/backups/etc
cp -r /etc/apache2/ /root/backups/etc
cp -r /etc/mysql/ /root/backups/etc
cp -r /etc/php5/ /root/backups/etc
cp -r /etc/ssh/ /root/backups/etc
cp -r /etc/cron* /root/backups/etc
cp -r /etc/sssd/ /root/backups/etc
cp -r /etc/pam.d/ /root/backups/etc
cp -r /var/www/ /root/backups/var
cp -r /var/lib/mysql/ /root/backups/var
cp -r /var/log/ /root/backups/var
cp -r /home/ /root/backups

# weird freebsd stuff
cp /etc/master.passwd /root/backups/etc
