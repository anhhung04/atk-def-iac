#!/usr/bin/env python3

import sys
import requests

from checklib import *
from web_lib import *

class Checker(BaseChecker):
    vulns: int = 1
    timeout: int = 5
    uses_attack_data: bool = True

    def __init__(self, *args, **kwargs):
        super(Checker, self).__init__(*args, **kwargs)
        self.mch = CheckMachine(self)

    def action(self, action, *args, **kwargs):
        try:
            super(Checker, self).action(action, *args, **kwargs)
        except requests.exceptions.ConnectionError:
            self.cquit(Status.DOWN, 'Connection error', 'Got requests connection error')

    def check(self):
        session = get_initialized_session()
        note_title = rnd_string(10)
        flag_value = rnd_string(20)

        self.mch.share_note(session, note_title, flag_value)
        fetched_data = self.mch.sqli_fetch_note(session, note_title, Status.MUMBLE)

        fetched_value = fetched_data[0]['value'] if fetched_data else None
        
        self.assert_eq(fetched_value, flag_value, "Note content mismatch")
        self.cquit(Status.OK)

    def put(self, flag_id: str, flag: str, vuln: str):
        session = get_initialized_session()
        note_title = rnd_string(10)
        self.mch.share_note(session, note_title, flag)
        self.cquit(Status.OK, note_title, f'{note_title}:{flag}')

    def get(self, flag_id: str, flag: str, vuln: str):
        session = get_initialized_session()
        note_title, _ = flag_id.split(':')
        fetched_data = self.mch.sqli_fetch_note(session, note_title, Status.CORRUPT)
        fetched_flag = fetched_data[0]['value'] if fetched_data else None
        self.assert_eq(fetched_flag, flag, "Note mismatch", Status.CORRUPT)
        self.cquit(Status.OK)



if __name__ == '__main__':
    c = Checker(sys.argv[2])
    try:
        c.action(sys.argv[1], *sys.argv[3:])
    except c.get_check_finished_exception():
        cquit(Status(c.status), c.public, c.private)
