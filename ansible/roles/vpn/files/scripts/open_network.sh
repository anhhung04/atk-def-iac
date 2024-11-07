#!/bin/bash

iptables -A ufw-before-forward -m set --match-set same-team src,dst -j ACCEPT
iptables -A ufw-before-forward -m set --match-set team-vulnbox src,dst -j ACCEPT
