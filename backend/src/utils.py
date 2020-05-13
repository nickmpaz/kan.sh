import json
import boto3
import logging
from boto3.dynamodb.conditions import Key, Attr

logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)


class Status:
    OK = {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': ''
    }
    forbidden = {
        'statusCode': 403,
        'headers': {'Content-Type': 'application/json'},
        'body': ''
    }
    not_found = {
        'statusCode': 404,
        'headers': {'Content-Type': 'application/json'},
        'body': ''
    }


class Response:
    create_board_response = 'create_board_response'
    delete_board_response = 'delete_board_response'
    get_boards_response = 'get_boards_response'
    update_board_contents_response = 'update_board_contents_response'


def send_to_connection(message, data, connection_id, callback_url):
    payload = json.dumps({'message': message, 'data': data}).encode('utf-8')
    gatewayapi = boto3.client(
        "apigatewaymanagementapi", endpoint_url=callback_url)
    logging.info('Sending to connection: %s\n%s' % (connection_id, str(payload)))
    try:
        gatewayapi.post_to_connection(ConnectionId=connection_id, Data=payload)
    except gatewayapi.exceptions.GoneException:
        # connection is no longer there, remove connection from the database
        dynamodb = boto3.resource('dynamodb')
        connection_pool_table = dynamodb.Table('connection_pool')
        response = connection_pool_table.scan(
            FilterExpression=Attr('connection_id').eq(connection_id)
        )

        
        if len(response['Items'] == 0):
            return

        # in theory(?) there can only be one entry with this connection id
        item = response['Items'][0]
        disconnected_user = item['user_id']
        connection_pool_table.delete_item(
            Key={
                'user_id': disconnected_user
            }
        )


def get_current_connection_info(event):
    domain = event.get("requestContext").get("domainName")
    stage = event.get("requestContext").get("stage")
    connection_id = event.get("requestContext").get("connectionId")
    callback_url = "https://%s/%s" % (domain, stage)
    return connection_id, callback_url


def get_connection_info(user_id):
    dynamodb = boto3.resource('dynamodb')
    connection_pool_table = dynamodb.Table('connection_pool')
    response = connection_pool_table.get_item(
        Key={
            'user_id': user_id,
        }
    )
    item = response.get('Item')
    if item:
        return item.get('connection_id'), item.get('callback_url')

    return False, False


def push_boards_to_connection(user_id, connection_id, callback_url):
    dynamodb = boto3.resource('dynamodb')
    user_boards_table = dynamodb.Table('user_boards')

    response = user_boards_table.query(
        KeyConditionExpression=Key('user_id').eq(user_id)
    )

    items = response['Items']
    # sort on updated at
    items.sort(key=lambda x: float(x.get('updated_at', 0)), reverse=True)
    boards = [{'board_id': item['board_id'],
               'board_name': item['board_name']} for item in items]
    data = {'boards': boards}
    send_to_connection(Response.get_boards_response,
                       data, connection_id, callback_url)
