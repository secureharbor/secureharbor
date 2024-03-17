import psycopg2
import time

# Process_logs will pick up data from table "logs"
# Run presidio/llama2 to analyze the data
# And update the data to table "processed_logs"

# Database connection parameters
dbname = "hackathon316"
user = "postgres"
password = "password"
host = "localhost"
port = "5432"

# Establish connection
try:
    connection = psycopg2.connect(
        dbname=dbname,
        user=user,
        password=password,
        host=host,
        port=port
    )
    print("Connected to the database!")

    # Create a cursor object
    cursor = connection.cursor()

    # Execute a query
    cursor.execute("SELECT MAX(row_updated_at) FROM processed_logs")

    # Fetch the results
    row = cursor.fetchone()

    last_updated_time = 0
    if row[0] is None:
        last_updated_time = 0
    else:
        print(row)
        last_updated_time = row[0]

    cursor.execute("SELECT * FROM logs where updated_at > %s",
                   (last_updated_time, ))

    unprocessed_logs = cursor.fetchall()

    # Process the results
    for row in unprocessed_logs:
        id = row[0]
        raw_data = row[1]
        pii_data = raw_data[:4]
        row_updated_at = row[3]
        created_at = time.time()
        sql = """INSERT INTO processed_logs (id, raw_data, pii_data, row_updated_at, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s)"""
        data = (id, raw_data, pii_data, row_updated_at, created_at, created_at)
        cursor.execute(sql, data)
        connection.commit()

    # Close cursor and connection
    cursor.close()
    connection.close()

except psycopg2.Error as e:
    print("Error connecting to the database:", e)
