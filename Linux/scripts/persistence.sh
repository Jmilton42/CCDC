#!/bin/bash

# Get user crontabs
users=$(cat /etc/passwd | grep -vE '(false|nologin|sync)$' | grep -E '/.*sh$' | cut -d':' -f1)
for user in $users; do
    crontab -u $user -l 2>/dev/null
done

# Get system crontabs
cat /etc/crontab
for file in /etc/cron.d/* /etc/cron.daily/* /etc/cron.hourly/* /etc/cron.monthly/* /etc/cron.weekly/*; do
    [ -e "$file" ] || continue
    cat "$file"
done

# move profiles
find /root /home -name '.*rc' -exec mv {} {}.bak \;
find /root /home -name '.*profile' -exec mv {} {}.bak \;
