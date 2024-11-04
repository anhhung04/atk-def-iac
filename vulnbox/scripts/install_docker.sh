#!/bin/bash

set -e
set -o pipefail

if [ -z "$(which docker)" ]; then
    sudo apt-get update
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
fi
