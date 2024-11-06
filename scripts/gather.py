#!/usr/bin/env python3
import os
import tarfile

teams = sorted(os.listdir("../ansible/roles/vpn/files/out"))
teams.pop(0)

os.makedirs("./out", exist_ok=True)

tokens = open("./tokens.txt", "r").readlines()

tokens = [t.strip().split(":")[1] for t in tokens]

for team in teams:
    tar = tarfile.open(f"./out/{team}.tar.gz", "w:gz")
    tar.add(f"../ansible/roles/vpn/files/out/{team}", arcname="vpn")
    tar.addfile(
        tarfile.TarInfo("vulnbox.txt"),
        """
IP: 10.80.{}.2
User: ubuntu
Password: R00tP@ss
Team token: {}  
    """.format(
            team[-1], tokens[int(team[-1]) - 1]
        ).encode(),
    )
    tar.add(f"./ssh_keys/{team}/id_ed25519", arcname="id_ed25519")
    tar.close()
