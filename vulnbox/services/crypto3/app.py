from flask import Flask, render_template, request, redirect, url_for, session
import sqlite3
import os
import datetime
from ecc import *
import sys

app = Flask(__name__)
app.secret_key = os.urandom(32)


# Initialize the SQLite3 database
def init_db():
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute("DROP TABLE IF EXISTS users")
    cursor.execute("DROP TABLE IF EXISTS user_log")
    cursor.execute("DROP TABLE IF EXISTS user_note")

    cursor.execute(
        """
            CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            privkey TEXT NOT NULL
        )"""
    )
    cursor.execute(
        """
            CREATE TABLE user_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            pubkey TEXT NOT NULL,
            note_id TEXT NOT NULL,
            log_id TEXT NOT NULL,
            action TEXT
        )"""
    )
    cursor.execute(
        """
            CREATE TABLE user_note (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            note_id TEXT NOT NULL,
            note TEXT NOT NULL
            
        )"""
    )
    conn.commit()
    conn.close()


init_db()


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        conn = sqlite3.connect("users.db")
        cursor = conn.cursor()
        if password := request.form.get("password"):
            password = request.form["password"]
            cursor.execute(
                "SELECT * FROM users WHERE username = ? AND password = ?",
                (username, password),
            )
        elif privkey := int(request.form.get("privkey")):
            cursor.execute(
                "SELECT * FROM users WHERE username = ? AND privkey = ?",
                (username, str(privkey)),
            )
        else:
            return "Invalid password"
        user = cursor.fetchone()
        conn.close()

        if user:
            session["username"] = username
            return redirect(url_for("home"))
        else:
            return "Invalid credentials"
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.pop("username", None)
    return redirect(url_for("home"))


@app.route("/store_data", methods=["POST"])
def store_data():
    if "username" not in session:
        return redirect(url_for("login"))

    username = session.get("username")
    data = request.form.get("data")
    note_id = os.urandom(32).hex()

    try:
        conn = sqlite3.connect("users.db")
        cursor = conn.cursor()

        cursor.execute(
            "INSERT INTO user_note (username, note_id, note) VALUES (?, ?, ?)",
            (username, note_id, data),
        )

        privkey = cursor.execute(
            "SELECT privkey FROM users WHERE username = ?", (username,)
        ).fetchone()
        privkey = int(privkey[0])

        pubkey = get_pubkey(privkey)
        log_id = sign(
            privkey, datetime.datetime.now().strftime("%Y-%m-%d") + "|" + note_id
        )

        cursor.execute(
            "INSERT INTO user_log (username, pubkey, note_id, log_id, action) VALUES (?, ?, ?, ?, ?)",
            (username, str(pubkey), note_id, str(log_id), "1"),
        )
        conn.commit()

    except Exception as e:
        conn.rollback()
        print(f"Error: {e}", file=sys.stderr)
        return "An error occurred while storing data", 500

    finally:
        conn.close()

    return f"Data stored successfully, Note ID: {note_id}"


@app.route("/read_data", methods=["POST"])
def read_data():
    if "username" not in session:
        return redirect(url_for("login"))

    username = session.get("username")
    note_id = request.form["note_id"]
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    data = cursor.execute(
        "SELECT username, note FROM user_note WHERE note_id = ?", (note_id,)
    ).fetchone()
    if data[0] == username:
        to_return = data[1]
    else:
        to_return = "Insufficient permissions"
    privkey = cursor.execute(
        "SELECT privkey FROM users WHERE username = ?", (username,)
    ).fetchone()
    privkey = int(privkey[0])
    pubkey = get_pubkey(privkey)
    log_id = sign(privkey, datetime.datetime.now().strftime("%Y-%m-%d") + "|" + note_id)
    cursor.execute(
        "INSERT INTO user_log (username, pubkey, note_id, log_id, action) VALUES (?, ?, ?, ?, ?)",
        (username, str(pubkey), note_id, str(log_id), "0"),
    )
    conn.commit()
    conn.close()

    return to_return


@app.route("/log", methods=["GET"])
def view_pubkey():
    if "username" not in session:
        return redirect(url_for("login"))

    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM user_log")
    logs = cursor.fetchall()
    conn.close()
    return "\n".join(str(x) for x in logs)


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        privkey, pubkey = generateKeyPair()
        pubkey = f"{pubkey[0]}, {pubkey[1]}"
        conn = sqlite3.connect("users.db")
        cursor = conn.cursor()
        try:
            cursor.execute(
                "INSERT INTO users (username, password, privkey) VALUES (?, ?, ?)",
                (username, password, str(privkey)),
            )
            conn.commit()
        except sqlite3.IntegrityError:
            return "Username already exists"
        finally:
            conn.close()

        return str(privkey)
    return render_template("register.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000)
