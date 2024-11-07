#!/usr/bin/env python3
import os
import tarfile
import io

teams = sorted(os.listdir("../ansible/roles/vpn/files/out"))
teams.pop(0)

os.makedirs("./out", exist_ok=True)

tokens = open("./tokens.txt", "r").readlines()

tokens = [t.strip().split(":")[1] for t in tokens]

for team in teams:
    tar = tarfile.open(f"./out/{team}.tar.gz", "w:gz")
    tar.add(f"../ansible/roles/vpn/files/out/{team}", arcname="vpn")
    info = tarfile.TarInfo("vulnbox.txt")
    password = open(f"../ansible/roles/vulnbox/files/passwords/{team}.txt", "r").read()
    content = f"""IP: 10.80.{team[-1]}.2
User: ubuntu
Password: {password}
Team token: {tokens[int(team[-1]) - 1]}""".encode()
    info.size = len(content)
    info.mode = 0o644
    tar.addfile(info, io.BytesIO(content))
    tar.add(f"./ssh_keys/{team}/id_ed25519", arcname="id_ed25519")
    tar.close()
