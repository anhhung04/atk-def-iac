#!/usr/bin/env python3
import string
import random
import sys
import os

TEAMS = int(sys.argv[1])

PASSWORDS_PATH = "../ansible/roles/vulnbox/files/passwords"

os.makedirs(PASSWORDS_PATH, exist_ok=True)


def randstr(l=16):
    return "".join(random.choices(string.ascii_letters + string.digits + "#@!&%", k=l))


for i in range(TEAMS):
    rand = randstr(48)
    open(f"{PASSWORDS_PATH}/team{str(i + 1)}.txt", "w+").writelines(rand)
