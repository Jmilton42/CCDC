#!/bin/bash

pkg=$(which apt||which yum||which pacman||which apk||which zypper||which dnf)

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
    *)
        echo "[-] Could not find a package manager. Run pspy manually"
        ;;
esac

curl -Ls https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | bash > /root/linpeas.txt &

curl -L -s https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh | bash > /root/les.txt &

curl -L -s https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh | bash -s -- stable
echo -e "[snoopy]\noutput = file:/root/snoopy.log" > /etc/snoopy.ini

curl -Ls https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64 -o /usr/local/bin/pspy64 && chmod +x /usr/local/bin/pspy64
echo '/usr/local/bin/pspy64 -p=false -i 1000 -f -r /var -r /etc -r /home | grep -E "CLOSE_WRITE"' > /root/pspy.sh && chmod +x /root/pspy.sh
screen -dmS pspy /root/pspy.sh
