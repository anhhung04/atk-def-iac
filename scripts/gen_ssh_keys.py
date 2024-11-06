#!/usr/bin/python3
import os
import subprocess
import shutil

os.makedirs("./ssh_keys", exist_ok=True)


def gen_ssh_keys(path):
    subprocess.run(
        ["ssh-keygen", "-t", "ed25519", "-f", f"{path}/id_ed25519", "-N", ""]
    )


teams = sorted(os.listdir("../ansible/roles/vpn/files/out"))

teams.pop(0)

for team in teams:
    os.makedirs(f"./ssh_keys/{team}", exist_ok=True)
    gen_ssh_keys(f"./ssh_keys/{team}")
    shutil.copy(
        f"./ssh_keys/{team}/id_ed25519.pub",
        f"../ansible/roles/vulnbox/files/{team}_id_ed25519.pub",
    )
