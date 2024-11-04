#!/usr/bin/python3
import os
import subprocess
import shutil
import sys

TEAMS = int(sys.argv[1])
SSH__PUBLIC_PATH = "../ansible/roles/vulnbox/files/ssh_keys"


def gen_ssh_keys(path):
    subprocess.run(
        ["ssh-keygen", "-t", "ed25519", "-f", f"{path}/id_ed25519", "-N", ""]
    )


os.makedirs("./ssh_keys", exist_ok=True)
os.makedirs(SSH__PUBLIC_PATH, exist_ok=True)
for team in range(TEAMS):
    team = f"team{str(team + 1)}"
    os.makedirs(f"./ssh_keys/{team}", exist_ok=True)
    gen_ssh_keys(f"./ssh_keys/{team}")
    shutil.copy(
        f"./ssh_keys/{team}/id_ed25519.pub",
        f"{SSH__PUBLIC_PATH}/{team}_id_ed25519.pub",
    )
