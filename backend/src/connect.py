import boto3

from src.auth import verify_jwt
from src.utils import Status

def handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: 
        return Status.forbidden

    # insert into connection pool
    dynamodb = boto3.resource('dynamodb')
    connection_pool_table = dynamodb.Table('connection_pool')
    user_id = claims['username']
    domain = event.get("requestContext").get("domainName")
    stage = event.get("requestContext").get("stage")
    callback_url = "https://%s/%s" % (domain, stage)
    connection_id = event.get("requestContext").get("connectionId")

    connection_pool_table.put_item(
        Item={
            'user_id': user_id,
            'connection_id': connection_id,
            'callback_url': callback_url
        }
    )
    return Status.OK