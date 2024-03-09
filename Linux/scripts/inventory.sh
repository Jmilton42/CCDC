#!/bin/bash

get_mac() {
    tool=$(which ip||which ifconfig)
    case $tool in
        *ip*)
            ip a | grep -E "link/ether " | awk '{print $2}'
            ;;
        *ifconfig*)
            ifconfig | grep -E "ether " | awk '{print $2}'
            ;;
        *)
            echo "[-] Could not find a command to get the MAC address"
            ;;
    esac
}

get_ip() {
    tool=$(which hostname||which ip||which ifconfig)
    case $tool in
        *hostname*)
            hostname -I
            ;;
        *ip*)
            ip a | grep -E "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d'/' -f1
            ;;
        *ifconfig*)
            ifconfig | grep -E "inet " | grep -v "127.0.0.1" | awk '{print $2}'
            ;;
        *)
            echo "[-] Could not find a command to get the IP address"
            ;;
    esac
}

# grab ID from /etc/os-release
echo "Hostname: $(hostname)"
echo "OS: $(grep PRETTY /etc/os-release | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Package Manager: $(which apt||which yum||which pacman||which apk||which zypper||which dnf||which pkg)"
echo "IP: $(get_ip)"
echo "MAC: $(get_mac)"
echo -e "Users:\n $(cat /etc/passwd | grep -vE '(false|nologin|sync)$' | grep -E '/.*sh$')"
echo -e "Admins:\n $(grep -E "sudo|wheel" /etc/group | cut -d':' -f4)"
echo -e "Active Services:\n $(systemctl list-units --type=service --state=active | grep -E "running" | awk '{print $1}' || service --status-all | grep -E "\[ \+ +\]" | awk '{print $4}' || echo idk what to put here)"

mkdir -p /root/initial
ss -tunlp > /root/initial/ss-tunlp.txt || netstat -tunlp > /root/initial/netstat-tunlp.txt
ps aux > /root/initial/ps-aux.txt > /root/initial/ps-aux.txt
ps auxf > /root/initial/ps-auxf.txt


