import psycopg2

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
    cursor.execute("SELECT * FROM logs")

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
