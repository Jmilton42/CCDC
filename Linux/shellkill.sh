#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "[-] This script must be run as root"
    exit 1
fi

shells=("bash" "sh" "zsh" "/bin/bash" "/bin/sh" "/bin/zsh")
parents=("ncat" "nc" "netcat" "php" "python" "python3" "perl" "ruby" "java" "socat" "telnet" "apache2" "httpd" "nginx")

while true; do
    for shell in "${shells[@]}"; do
        for parent in "${parents[@]}"; do
            evil=$(ps ef | grep "\_ $shell" | grep "$parent" | grep -v "grep" | awk '{print $1}')
            if [[ ! -z "$evil" ]]; then
                echo "Webshell spawned by $parent detected. Killing PID $evil"
                kill -9 $evil
            fi
        done
    done
    sleep 1
done


# for shell in "${shells[@]}"; do
#     ps aux | grep -i "$shell" | grep -v "grep" | awk '{print $2}' | xargs -I{} ps -o ppid= -p {} | xargs -I{} ps -o comm= -p {} | [[ " $parents " =~ " {} " ]] && echo "Killing {}"
# done
