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
        note_content = rnd_string(100)
        note_id = self.mch.add_note(note_content)
        self.assert_in(
            f"Note added successfully with ID: {note_id}", self.mch.view_notes()
        )

        notes = self.mch.view_notes()
        assert_in(note_content, notes)

        new_content = rnd_string(50)

        self.mch.edit_note(note_id, new_content)
        self.assert_in(new_content, c.view_notes())

    def put(self, flag_id: str, flag: str):
        ssn = rnd_string(9)

        self.mch.add_document(ssn, flag)
        self.cquit(Status.OK, ssn, f"{ssn}:{flag}")

    def get(self, flag_id: str, flag: str):
        ssn, _ = flag_id.split(":")
        fetched_flag = self.mch.sqli_fetch_document(ssn)

        self.assert_in(flag, fetched_flag, "Flag mismatch", Status.CORRUPT)
        self.cquit(Status.OK)


if __name__ == "__main__":
    c = Checker(sys.argv[2])
    try:
        c.action(sys.argv[1], *sys.argv[3:])
    except c.get_check_finished_exception():
        cquit(Status(c.status), c.public, c.private)
