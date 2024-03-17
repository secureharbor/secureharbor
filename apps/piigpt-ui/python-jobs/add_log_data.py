import psycopg2
import uuid
import time
import argparse

# Add the data to logs table.

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

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", help="data to be stored")
    args = parser.parse_args()
    user_input = format(args.i)
    random_uuid = str(uuid.uuid4())
    print(random_uuid)
    # Define your SQL statement to insert data into a table
    sql = """INSERT INTO logs (id, name, created_at, updated_at)
         VALUES (%s, %s, %s, %s)"""

# Define the data to be inserted
    current_time_seconds = time.time()
    data = (random_uuid, user_input, current_time_seconds, current_time_seconds)

    # Create a cursor object
    cursor = connection.cursor()
    # Execute the SQL statement
    cursor.execute(sql, data)

# Commit the transaction
    connection.commit()

    # Execute a query
    cursor.execute("SELECT * FROM log_data")

    # Fetch the results
    results = cursor.fetchall()

    # Process the results
    for row in results:
        print(row)  # This will print each row of the result

    # Close cursor and connection
    cursor.close()
    connection.close()

except psycopg2.Error as e:
    print("Error connecting to the database:", e)
