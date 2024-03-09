#!/bin/bash

pkg=$(which apt||which yum||which pacman||which apk||which zypper||which dnf||which pkg)

if [[ -z "$pkg" ]]; then
    echo "[-] Could not find a package manager. Run pspy manually"
fi

case $pkg in
    *apt*)
        apt install -y screen
        ;;
    *yum*)
        yum install -y screen
        ;;
    *pacman*)
        pacman -S --noconfirm screen
        ;;
    *apk*)
        apk add screen
        ;;
    *zypper*)
        zypper install -y screen
        ;;
    *dnf*)
        dnf install -y screen
        ;;
    *pkg*)
        pkg install -y screen
        ;;
    *)
        echo "[-] Could not find a package manager. Run pspy manually"
        ;;
esac

mkdir -p /root/logs

curl -Ls https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh | bash -s -- stable
# echo -e "[snoopy]\noutput = file:/root/logs/snoopy.log" > /etc/snoopy.ini

echo 'curl -Ls https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | bash > /root/logs/linpeas.txt' > /root/linpeas.sh && chmod +x /root/linpeas.sh
screen -dmS linpeas /root/linpeas.sh

echo 'curl -Ls https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh | bash > /root/logs/les.txt' > /root/les.sh && chmod +x /root/les.sh
screen -dmS les /root/les.sh

curl -Ls https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64 -o /usr/local/bin/pspy64 && chmod +x /usr/local/bin/pspy64
echo '/usr/local/bin/pspy64 -p=false -i 1000 -f -r /var -r /etc -r /home | grep -E "CLOSE_WRITE"' > /root/pspy.sh && chmod +x /root/pspy.sh
screen -dmS pspy /root/pspy.sh

echo 'grep -Er "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" / 2>/dev/null' > /root/rev.sh && chmod +x /root/ip.sh
screen -dmS revshell /root/rev.sh

os=$(which apt||which yum||which pacman||which apk||which zypper||which dnf||which pkg)
if [[ $(cat "$os" | grep -E "yum|dnf") ]]; then
    screen -dmS monitor tail -f /var/log/secure
else
    screen -dmS monitor tail -f /var/log/auth.log
fi
