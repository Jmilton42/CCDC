#!/bin/sh

pkg=$(which apt||which yum||which pacman||which apk||which zypper||which dnf||which pkg)

case $pkg in
    *apt*)
        apt update -y
        apt install -y net-tools iproute2 sed git bash curl wget python3 python3-pip iptables
        apt purge -y ncat socat netcat
        rm -f /usr/bin/nc /bin/nc
        ;;
    *yum*)
        yum update -y
        yum install -y net-tools iproute sed git bash curl wget python3 python3-pip iptables
        yum remove -y nmap-ncat socat
        rm -f /usr/bin/nc /bin/nc
        ;;
    *pacman*)
        pacman -Syu --noconfirm
        pacman -S --noconfirm net-tools iproute2 sed git bash curl wget python python-pip iptables
        pacman -R --noconfirm gnu-netcat socat
        rm -f /usr/bin/nc /bin/nc
        ;;
    *apk*)
        echo "http://mirrors.ocf.berkeley.edu/alpine/v3.16/community" >> /etc/apk/repositories
        apk update
        apk add net-tools iproute2 sed git bash curl wget python3 py3-pip iptables iptraf-ng util-linux-misc
        apk del nmap-ncat socat
        rm -f /usr/bin/nc /bin/nc
        ;;
    *zypper*)
        zypper -n refresh
        zypper -n update
        zypper -n install net-tools iproute2 sed git bash curl wget python3 python3-pip iptables
        zypper -n remove gnu-netcat netcat openbsd-netcat socat ncat
        rm -f /usr/bin/nc /bin/nc
        ;;
    *dnf*)
        dnf check-update
        dnf update -y
        dnf install -y net-tools iproute sed git bash curl wget python3 python3-pip iptables
        ;;
    *pkg*)
        pkg update
        pkg install -y git bash curl wget python39 py39-pip sudo
        ;;
    *)
        echo "[-] Could not find a package manager to install dependencies"
        ;;
esac

