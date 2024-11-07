#!/usr/bin/env python3

import subprocess, os
import logging, sys

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
log = logging.getLogger("network-config-generator")

OUT_DIR = "../ansible/roles/vpn/files/out"
TEAMS = int(sys.argv[1])
PER_TEAM = int(sys.argv[2])
VPN_DOMAIN = sys.argv[3]
SUBNET = "10.{0}.{1}.{2}"

SERVER_CFG = """[Interface]
PrivateKey = {private_key}
Address = {address}
ListenPort = {port}

{peers}
"""

PEER_CFG = """[Peer]
# {comment}
PublicKey = {public_key}
AllowedIPs = {allowed_ips}
"""

CLIENT_CFG = """[Interface]
PrivateKey = {private_key}
Address = {address}
{post_up}
{pre_down}

[Peer]
PublicKey = {public_key}
Endpoint = {endpoint}
AllowedIPs = {allowed_ips}
PersistentKeepalive = 5
"""


def create_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)


def clean_dir(path):
    if os.path.exists(path):
        subprocess.run(["rm", "-rf", path])


def write(path, data):
    with open(path, "w") as f:
        f.write(data)


def get_client_ip(team, client):
    return SUBNET.format(60 + team // 256, team % 256, 2 + client) + "/32"


def generate_keys():
    private_key = subprocess.check_output(["wg", "genkey"]).strip().decode("utf-8")
    public_key = (
        subprocess.check_output(["wg", "pubkey"], input=private_key.encode())
        .strip()
        .decode("utf-8")
    )
    return (private_key, public_key)


if __name__ != "__main__":
    print("This script is not meant to be imported.")
    sys.exit(0)

clean_dir(OUT_DIR)
create_dir(OUT_DIR)

SERVER_KEYS = generate_keys()
peers = []

for team in range(1, 1 + TEAMS):
    create_dir("{0}/team{1}".format(OUT_DIR, team))
    for user in range(1, 1 + PER_TEAM):
        USER_KEYS = generate_keys()
        write(
            "{0}/team{1}/member{2}.conf".format(OUT_DIR, team, user),
            CLIENT_CFG.format(
                private_key=USER_KEYS[0],
                public_key=SERVER_KEYS[1],
                address=get_client_ip(team, user),
                endpoint="{0}:51820".format(VPN_DOMAIN),
                allowed_ips="10.0.0.0/8",
                post_up="",
                pre_down="",
            ),
        )
        peers.append(
            PEER_CFG.format(
                comment="Team {0}, Member {1}".format(team, user),
                public_key=USER_KEYS[1],
                allowed_ips=get_client_ip(team, user),
            )
        )

write(
    "{0}/server.conf".format(OUT_DIR),
    SERVER_CFG.format(
        private_key=SERVER_KEYS[0],
        address="10.0.0.0/8",
        port="51820",
        peers="\n".join(peers),
    ),
)
