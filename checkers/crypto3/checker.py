#!/usr/bin/env python3

import sys
import requests
from checklib import *
from crypto_lib import *

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
        except requests.exceptions.Timeout:
            self.cquit(Status.DOWN, 'Timeout', 'Request timed out')

    def check(self):
        try:
            session = get_initialized_session()
            username = rnd_username()
            password = rnd_string(10)
            note_content = rnd_string(20)

            self.mch.register_user(session, username, password)
            self.mch.login(session, username, password)
            note_id = self.mch.store_data(session, note_content).split(": ")[-1]
            fetched_data = self.mch.read_data(session, note_id)

            self.assert_eq(fetched_data, note_content, "Stored data does not match fetched data", Status.CORRUPT)
            self.cquit(Status.OK)
        except AssertionError as e:
            self.cquit(Status.MUMBLE, 'Data mismatch or incorrect behavior', str(e))
        except requests.exceptions.RequestException as e:
            self.cquit(Status.DOWN, 'Request failure', str(e))

    def put(self, flag_id: str, flag: str, vuln: str):
        try:
            session = get_initialized_session()
            username = rnd_username()
            password = rnd_string(10)

            self.mch.register_user(session, username, password)
            self.mch.login(session, username, password)
            note_id = self.mch.store_data(session, flag).split(": ")[-1]
            self.cquit(Status.OK, note_id, f"{username}:{password}:{note_id}")
        except AssertionError as e:
            self.cquit(Status.MUMBLE, 'Error during data storage', str(e))
        except requests.exceptions.RequestException as e:
            self.cquit(Status.DOWN, 'Request failure', str(e))

    def get(self, flag_id: str, flag: str, vuln: str = None):
        try:
            session = get_initialized_session()
            username, password, note_id = flag_id.split(":")
            
            self.mch.login(session, username, password)
            fetched_data = self.mch.read_data(session, note_id)
            self.assert_eq(fetched_data, flag, "Fetched flag does not match", Status.CORRUPT)
            self.cquit(Status.OK)
            
        except AssertionError as e:
            self.cquit(Status.CORRUPT, 'Data corrupted', str(e))
        except requests.exceptions.RequestException as e:
            self.cquit(Status.DOWN, 'Request failure', str(e))

if __name__ == '__main__':
    c = Checker(sys.argv[2])
    try:
        c.action(sys.argv[1], *sys.argv[3:])
    except c.get_check_finished_exception():
        cquit(Status(c.status), c.public, c.private)
