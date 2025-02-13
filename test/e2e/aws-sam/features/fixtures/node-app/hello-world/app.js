exports.lambdaHandler = async (event, context) => {
    return {
        'statusCode': 201,
        'body': JSON.stringify({
            message: 'ah hah',
            event,
            context
        })
    }
}
