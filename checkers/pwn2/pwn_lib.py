#!/usr/bin/env python3

from checklib import *
from pwn import *
import string
import re

PORT = 31337


class CheckMachine:
    def __init__(self, checker: BaseChecker):
        self.c = checker

    def connect(self):
        self._conn = remote(self.c.host, PORT)

    def disconnect(self):
        self._conn.close()

    def readline(self):
        return self._conn.recvline().decode(errors="ignore").strip()

    def read_until(self, marker):
        return self._conn.recvuntil(marker.encode()).decode(errors="ignore")

    def choice(self, line):
        self._conn.sendlineafter("choice: ", line.encode())

    def add_note(self, content):
        self.choice("1")
        self._conn.sendlineafter(b"Enter your note content: ", content.encode())
        response = self._conn.recvline()
        match = re.search(r"Note added successfully with ID: (\d+)", response)
        self.c.assert_neq(match, None, "Failed to add note")
        return int(match.group(1))

    def view_notes(self):
        self.choice("2")
        return self.read_until("Your")

    def delete_note(self, note_id):
        self.choice("3")
        self._conn.sendlineafter(
            b"Enter the ID of the note you want to delete: ", str(note_id).encode()
        )
        return self.read_until("Your")

    def edit_note(self, note_id, new_content):
        self.choice("4")
        self._conn.sendlineafter(
            b"Enter the ID of the note you want to edit: ", str(note_id).encode()
        )
        self._conn.sendlineafter(b"Enter new content: ", new_content.encode())
        return self.read_until("Your")

    def print_user_info(self):
        self.choice("5")
        return self.read_until("Your")

    def create_super_note(self, size):
        self.choice("6")
        self._conn.sendafter("Enter the size of the super note: ", str(size).encode())
        return self.read_until("Your")
