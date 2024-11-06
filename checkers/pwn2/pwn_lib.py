from pwn import *
from checklib import *

context.log_level = 'warn'

PORT = 5501  

class CheckMachine:
    def __init__(self, checker: BaseChecker):
        self.c = checker
        self.host = self.c.host
        self.port = PORT

    def send_recv(self, data: str) -> str:
        conn = remote(self.host, self.port)
        conn.sendline(data.encode('utf-8'))
        response = conn.recvall().decode('utf-8')
        conn.close()
        return response

    def add_document(self, ssn: str, content: str):
        interaction = f"1\n{ssn}\n{content}\n"
        response = self.send_recv(interaction)
        self.c.assert_in("document", response, f"Failed to add document, response was: {response}")

    def fetch_document(self, ssn: str) -> str:
        interaction = f"2\n{ssn}\n"
        response = self.send_recv(interaction)
        self.c.assert_in("Your contents", response, "Failed to fetch document")
        return response

    def sqli_fetch_document(self, payload: str) -> str:
        interaction = f"2\n{payload}\n"
        response = self.send_recv(interaction)
        self.c.assert_in("Your contents", response, "Failed to fetch document via SQLi")
        return response