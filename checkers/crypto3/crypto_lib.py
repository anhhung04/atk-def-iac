import requests
from checklib import *

PORT = 10000  

class CheckMachine:
    @property
    def url(self):
        return f"http://{self.c.host}:{self.port}"

    def __init__(self, checker: BaseChecker):
        self.c = checker
        self.port = PORT

    def register_user(self, session: requests.Session, username: str, password: str):
        url = f"{self.url}/register"
        response = session.post(url, data={"username": username, "password": password})
        self.c.assert_eq(response.status_code, 200, "User registration failed")

    def login(self, session: requests.Session, username: str, password: str):
        url = f"{self.url}/login"
        response = session.post(url, data={"username": username, "password": password})
        self.c.assert_eq(response.status_code, 200, "Login failed")
    
    def store_data(self, session: requests.Session, data: str):
        url = f"{self.url}/store_data"
        response = session.post(url, data={"data": data})
        self.c.assert_eq(response.status_code, 200, "Storing data failed")
        return self.c.get_text(response, "Invalid response on storing data")

    def read_data(self, session: requests.Session, note_id: str):
        url = f"{self.url}/read_data"
        response = session.post(url, data={"note_id": note_id})
        self.c.assert_eq(response.status_code, 200, "Reading data failed")
        return self.c.get_text(response, "Invalid response on reading data")
