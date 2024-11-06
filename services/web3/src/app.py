from flask import Flask, request, render_template, jsonify
import sqlite3

app = Flask(__name__)

# Connect to the database
def get_db_connection():
    conn = sqlite3.connect('database.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/')
def index():
    return render_template('home.html')

@app.route('/share', methods=['POST'])
def share_note():
    note_name = request.json.get('title')
    note_content = request.json.get('content')
    conn = get_db_connection()

    try:
        conn.execute("INSERT INTO notes (name, value) VALUES (?, ?)", (note_name, note_content))
        conn.commit()
        return jsonify(success=True)
    except sqlite3.IntegrityError:
        return jsonify(success=False, error="A note with this title already exists."), 400
    except sqlite3.Error as e:
        return jsonify(success=False, error="An error occurred while sharing the note: " + str(e)), 500

@app.route('/retrieve', methods=['POST'])
def retrieve_note():
    note_title = request.json.get('title')
    conn = get_db_connection()

    query = f"SELECT value FROM notes WHERE name = '{note_title}'"
    
    try:
        result = conn.execute(query).fetchall()
        if result:
            result_dict = [dict(row) for row in result]
            return jsonify(success=True, content=result_dict)
        return jsonify(success=False, error="Note not found."), 404
    except sqlite3.Error as e:
        return jsonify(success=False, error="An error occurred while retrieving the note: " + str(e)), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)