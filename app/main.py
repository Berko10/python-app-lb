from flask import Flask, request, jsonify, make_response
import mysql.connector
import socket
from datetime import datetime
import os
import logging

log_path = "/app/logs/app.log"
os.makedirs(os.path.dirname(log_path), exist_ok=True)

# קביעת הגדרות הלוגים
logging.basicConfig(
    filename=log_path,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

app = Flask(__name__)

db_config = {
    'host': 'db',
    'user': 'root',
    'password': 'root',
    'database': 'app_db'
}

def get_counter():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("SELECT value FROM counter WHERE id = 1")
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    logging.info(f"Fetched counter value: {result[0] if result else 0}")
    return result[0] if result else 0

def update_counter(value):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("UPDATE counter SET value = %s WHERE id = 1", (value,))
    conn.commit()
    cursor.close()
    conn.close()
    logging.info("Counter updated successfully")

def log_access(client_ip, internal_ip, hostname):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO access_log (access_time, client_ip, internal_ip) VALUES (%s, %s, %s)",
        (datetime.now(), client_ip, internal_ip,)
    )
    conn.commit()
    cursor.close()
    conn.close()
    logging.info("Access logged successfully")

@app.route('/')
def index():
    counter = get_counter() + 1
    update_counter(counter)

    current_internal_ip = socket.gethostbyname(socket.gethostname())
    hostname = socket.gethostname()

    client_real_ip = request.remote_addr
    logging.info(f"Client IP: {client_real_ip}, Internal IP: {current_internal_ip}, Hostname: {hostname}")

    cookie_internal_ip = request.cookies.get('internal_ip')

    is_new_cookie = False
    if cookie_internal_ip:
        selected_internal_ip = cookie_internal_ip
        cookie_status = "(existing cookie)"
    else:
        selected_internal_ip = current_internal_ip
        cookie_status = "(new cookie)"
        is_new_cookie = True

    logging.info(f"Cookie status: {cookie_status}, Selected internal IP: {selected_internal_ip}")

    resp = make_response(f"""Internal IP: {selected_internal_ip}<br>""")

    if is_new_cookie:
        resp.set_cookie('internal_ip', selected_internal_ip, max_age=300)
        logging.info("New internal IP cookie set")

    log_access(client_real_ip, selected_internal_ip, hostname)

    return resp

@app.route('/showcount')
def show_count():
    logging.info("Show count route accessed")
    return jsonify({'counter': get_counter()})

if __name__ == '__main__':
    logging.info("Starting Flask app")
    app.run(debug=True, host='0.0.0.0')