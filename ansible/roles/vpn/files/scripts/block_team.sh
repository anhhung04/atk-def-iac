#!/bin/bash

TEAM_ID=$1
client_ips="10.$((60 + i / 256)).$((i % 256)).0/16"
ufw route insert from $client_ips to 10.0.0.0/8 0
