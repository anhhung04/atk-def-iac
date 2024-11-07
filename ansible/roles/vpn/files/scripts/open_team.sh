#!/bin/bash

TEAM_ID=$1
client_ips="10.$((60 + TEAM_ID / 256)).$((TEAM_ID % 256)).0/16"
ufw route delete from $client_ips to 10.80.0.0/16
