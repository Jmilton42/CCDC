#!/bin/bash

# thanks UCI!!!!!

if ! [ -z "$1" ]; then
    find_path="$1"
fi

grep_for_phone_numbers() {
    grep -REo '(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}' $1 2>/dev/null
}

grep_for_email_addresses() {
    grep -REo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}' $1 2>/dev/null
}

grep_for_social_security_numbers() {
    grep -REo '[0-9]{3}-[0-9]{2}-[0-9]{4}' $1 2>/dev/null
}


grep_for_credit_card_numbers() {
    grep -REo '^(?:\d{4}-?){3}\d{4}$|^(?:\d{4}\s?){3}\d{4}$|^(?:\d{4}){4}$' $1 2>/dev/null
}

grep_for_vehicle_regisration_numbers() {
    grep -REo '[A-Z]{1,2}[0-9]{1,2}\s?[A-Z]{1,3}\s?[0-9]{1,4}' $1 2>/dev/null
}

find_interesting_files_by_extension() {
    find $1 -type f -name '*.doc' -o -name '*.docx' -o -name '*.xls' -o -name '*.xlsx' -o -name '*.pdf' -o -name '*.ppt' -o -name '*.pptx' -o -name '*.txt' -o -name '*.rtf' -o -name '*.csv' -o -name '*.odt' -o -name '*.ods' -o -name '*.odp' -o -name '*.odg' -o -name '*.odf' -o -name '*.odc' -o -name '*.odb' -o -name '*.odm' -o -name '*.docm' -o -name '*.dotx' -o -name '*.dotm' -o -name '*.dot' -o -name '*.wbk' -o -name '*.xltx' -o -name '*.xltm' -o -name '*.xlt' -o -name '*.xlam' -o -name '*.xlsb' -o -name '*.xla' -o -name '*.xll' -o -name '*.pptm' -o -name '*.potx' -o -name '*.potm' -o -name '*.pot' -o -name '*.ppsx' -o -name '*.ppsm' -o -name '*.pps' -o -name '*.ppam' -o -name '*.pptx' 2>/dev/null
}

search() {
    grep_for_phone_numbers $1
    grep_for_email_addresses $1
    grep_for_social_security_numbers $1
    find_interesting_files_by_extension $1
    grep_for_credit_card_numbers $1
    grep_for_vehicle_regisration_numbers $1
}

if ! [ -z "$find_path" ]; then
    echo "[+] Searching $find_path for PII."
    search $find_path
fi

# look in /home
echo "[+] Searching /home for PII."
search /home

# look in /var/www
echo "[+] Searching /var/www for PII."
search /var/www

# looking in the backup file with all DB info ( /root/backups/sql/all_databases.sql )
# echo "[+] Searching DB backup file for PII."
# search /root/backups/sql/all_databases.sql

# if there is vsftpd installed, look in the anon_root and local_root directories
if [ -f /etc/vsftpd.conf ]; then
    echo "[+] VSFTPD config file found. Checking for anon_root and local_root directories."
    if [ -n "$(grep -E '^anon_root' /etc/vsftpd.conf)" ]; then
        echo -e "[+] anon_root found. Checking for PII."
        anon_root=$(grep -E '^anon_root' /etc/vsftpd.conf | awk '{print $2}')
        search $anon_root
    fi

    if [ -n "$(grep -E '^local_root' /etc/vsftpd.conf)" ]; then
        echo -e "[+] local_root found. Checking for PII."
        local_root=$(grep -E '^local_root' /etc/vsftpd.conf | awk '{print $2}')
        search $local_root
    fi
fi

#proftpd
if [ -f /etc/proftpd/proftpd.conf ]; then
    echo "[+] ProFTPD config file found. Checking for anon_root and local_root directories."
    if [ -n "$(grep -E '^DefaultRoot' /etc/proftpd/proftpd.conf)" ]; then
        echo -e "[+] DefaultRoot found. Checking for PII."
        default_root=$(grep -E '^DefaultRoot' /etc/proftpd/proftpd.conf | awk '{print $2}')
        search $default_root
    fi
fi

# samba
if [ -f /etc/samba/smb.conf ]; then
    echo "[+] Samba config file found. Checking for shares."
    shares=$(grep -E '^path' /etc/samba/smb.conf | awk '{print $3}' | sed 's/"//g')
    for share in $shares; do
        echo -e "[+] Checking $share for PII."
        search $share
    done
fi
