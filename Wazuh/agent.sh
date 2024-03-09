#!/bin/sh


if $(which dpkg > /dev/null 2>&1); then
    ufw allow out 53
    ufw allow out 443,80/tcp
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent_4.7.3-1_amd64.deb && sudo WAZUH_MANAGER='<insert manager>' dpkg -i ./wazuh-agent_4.7.3-1_amd64.deb

    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent

    ufw delete allow out 53
    ufw delete allow out 443,80/tcp
else
    ufw allow out 53
    ufw allow out 443,80/tcp
    
    curl -o wazuh-agent-4.7.3-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.3-1.x86_64.rpm && sudo WAZUH_MANAGER='<insert manager>' rpm -ihv wazuh-agent-4.7.3-1.x86_64.rpm
    
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    
    ufw delete allow out 53
    ufw delete allow out 443,80/tcp
fi
