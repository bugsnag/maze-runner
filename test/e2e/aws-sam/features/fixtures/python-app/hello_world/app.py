def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": """
            <html>
                <head><title>my cool page</title></head>

                <body>
                    <h1>my cool page</h1>

                    <p>stuff and things</p>
                </body>
            </html>
        """,
    }
