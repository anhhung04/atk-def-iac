#!/bin/bash

sudo mv /tmp/game-service@.service /etc/systemd/system/game-service@.service
sudo systemctl daemon-reload
services=("web1" "crypto1" "crypto2" "web2" "pwn1" "web3" "crypto3" "pwn2")
for service in "${services[@]}"; do
    sudo useradd -m -s /bin/bash $service
    sudo -H -u $service bash -c "cp -r /tmp/services/$service/* /home/$service/"
    sudo rm -rf /tmp/services/$service
    sudo su && cd /home/$service && docker compose pull --ignore-buildable && docker compose build
    sudo systemctl enable game-service@$service
done
