from flask import Flask, jsonify, request, render_template
import psycopg2

# API to show processed_logs data

app = Flask(__name__)
# Database connection parameters
dbname = "hackathon316"
user = "postgres"
password = "password"
host = "localhost"
port = "5432"

connection = psycopg2.connect(
    dbname=dbname,
    user=user,
    password=password,
    host=host,
    port=port
)
cursor = connection.cursor()


@app.route("/")
def hello_world():
    return render_template('index.html')


@app.route("/pii_data")
def pii_data_api():
    pii_logs = []
    cursor.execute("SELECT * FROM processed_logs")
    results = cursor.fetchall()
    for row in results:
        pii_logs.append({"id": row[0], "raw_data": row[1],
                         "pii_data": row[2], "row_time": row[3]})
    return jsonify({"pii_data": pii_logs})


@app.route("/pii_ui")
def pii_data_template():
    pii_logs = []
    cursor.execute("SELECT * FROM processed_logs")
    results = cursor.fetchall()
    for row in results:
        pii_logs.append({"id": row[0], "raw_data": row[1],
                         "pii_data": row[2], "row_time": row[3]})
    return render_template('pii_data.html', pii_logs=pii_logs)
