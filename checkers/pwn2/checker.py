#!/usr/bin/env python3

import sys
import requests
from checklib import *
from pwn_lib import *
import socket


class Checker(BaseChecker):
    vulns: int = 3
    timeout: int = 10
    uses_attack_data: bool = True

    def __init__(self, *args, **kwargs):
        super(Checker, self).__init__(*args, **kwargs)
        self.mch = CheckMachine(self)

    def action(self, action, *args, **kwargs):
        try:
            super(Checker, self).action(action, *args, **kwargs)
        except requests.exceptions.ConnectionError:
            self.cquit(
                Status.DOWN, "Connection error", "Could not connect to the service"
            )
        except ConnectionError:
            self.cquit(
                Status.DOWN, "Connection error", "Could not connect to the service"
            )

    def check(self):
        self.mch.connect()

        username = rnd_username(8)
        password = rnd_password(12)

        self.mch.register_user(username, password)
        self.mch.login_user(username, password)

        note_content = rnd_string(50)
        note_id = self.mch.add_note(note_content)

        notes = self.mch.view_notes()
        assert_in(note_content, notes, "Note not found", Status.MUMBLE)

        new_content = rnd_string(50)

        self.mch.edit_note(note_id, new_content)
        self.assert_in(new_content, self.mch.view_notes(), Status.MUMBLE)

        self.mch.delete_note(note_id)

        self.assert_nin(
            new_content, self.mch.view_notes(), "Note deletion failed", Status.MUMBLE
        )

        user_info = self.mch.print_user_info()

        self.assert_in("Username:", user_info, "Cannot get username")
        self.assert_in("Admin:", user_info, "Cannot check admin")

        self.mch.disconnect()

        self.cquit(Status.OK)

    def put(self, flag_id: str, flag: str, vuln=None):
        self.mch.connect()
        username = rnd_username(8)
        password = rnd_password(12)

        self.mch.register_user(username, password)

        self.mch.login_user(username, password)

        note_content = f"Secret information: {flag}"

        note_id = self.mch.add_note(rnd_string(50))

        self.mch.edit_note(note_id, note_content)

        self.mch.disconnect()

        self.cquit(Status.OK, username, f"{username}:{password}:{note_id}")

    def get(self, flag_id: str, flag: str, vuln=None):
        username, password, _ = flag_id.split(":")
        self.mch.connect()
        self.mch.login_user(username, password)

        notes = self.mch.view_notes()

        self.assert_in(flag, notes, "Note not found", Status.CORRUPT)

        self.mch.disconnect()

        self.cquit(Status.OK)


if __name__ == "__main__":
    c = Checker(sys.argv[2])
    try:
        c.action(sys.argv[1], *sys.argv[3:])
    except c.get_check_finished_exception():
        cquit(Status(c.status), c.public, c.private)
