import json
import time
import uuid

import boto3
from boto3.dynamodb.conditions import Key, Attr

from src.auth import verify_jwt
from src.utils import Status, Response, send_to_connection, get_current_connection_info, get_connection_info, push_boards_to_connection

user_pool_id = 'us-east-1_NSlmDs2SZ'





def disconnect_handler(event, context):
    # remove connection from connection pool
    dynamodb = boto3.resource('dynamodb')
    connection_pool_table = dynamodb.Table('connection_pool')
    connection_id = event.get("requestContext").get("connectionId")

    connection_pool_table.delete_item(
        Key={
            'connection_id': connection_id
        }
    )
    return Status.OK


def ping_handler(event, context):
    connection_id, callback_url = get_current_connection_info(event)
    send_to_connection('pong', 'pong', connection_id, callback_url)
    return Status.OK

def get_boards_handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: return Status.forbidden
    user_id = claims['username']
    connection_id, callback_url = get_current_connection_info(event)
    push_boards_to_connection(user_id, connection_id, callback_url)
    
    return Status.OK



def create_board_handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: return Status.forbidden
    
    dynamodb = boto3.resource('dynamodb')
    user_boards_table = dynamodb.Table('user_boards')
    board_cards_table = dynamodb.Table('board_cards')
    user_id = claims['username']

    # generate a board_id, check if it already exists
    board_id = uuid.uuid4().hex
    for i in range(100):
        response = user_boards_table.scan(
            FilterExpression=Attr('board_id').eq(board_id)
        )
        items = response['Items']
        if len(items) == 0:
            break

        board_id = uuid.uuid4().hex

    # create the board
    user_boards_table.put_item(
        Item={
            'user_id': user_id,
            'board_id': board_id,
            'board_name': 'Untitled',
            'updated_at': str(time.time())
        }
    )

    # create board contents
    board_cards_table.put_item(
        Item={
            'board_id': board_id,
            'board_contents': {
                'columns': json.dumps([
                    {'name': 'To Do', 'cards': []},
                    {'name': 'Doing', 'cards': []},
                    {'name': 'Done', 'cards': []},
                ]),
                'name': 'Untitled'
            }
        }
    )
    connection_id, callback_url = get_current_connection_info(event)
    send_to_connection(Response.create_board_response, {'board_id': board_id}, connection_id, callback_url)
    
    return Status.OK

def delete_board_handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: return Status.forbidden

    dynamodb = boto3.resource('dynamodb')
    user_boards_table = dynamodb.Table('user_boards')
    board_cards_table = dynamodb.Table('board_cards')
    board_id = json.loads(event.get("body")).get('board_id')
    user_id = claims['username']

    # check that user owns the board
    response = user_boards_table.get_item(
        Key={
            'user_id': user_id,
            'board_id': board_id
        }
    )
    item = response.get('Item')
    if not item: raise Exception

    # delete board for this user
    user_boards_table.delete_item(
        Key={
            'user_id': user_id,
            'board_id': board_id
        }
    )

    # if no one else owns the board delete the contents
    response = user_boards_table.scan(
        FilterExpression=Attr('board_id').eq(board_id)
    )
    items = response['Items']
    if len(items) == 0:
        # delete the board contents
        board_cards_table.delete_item(
            Key={
                'board_id': board_id
            }
        )
    # send response
    connection_id, callback_url = get_current_connection_info(event)
    send_to_connection(Response.delete_board_response, {'board_id': board_id}, connection_id, callback_url)
    return Status.OK

def get_board_contents_handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: return Status.forbidden

    dynamodb = boto3.resource('dynamodb')
    user_boards_table = dynamodb.Table('user_boards')
    board_cards_table = dynamodb.Table('board_cards')
    board_id = json.loads(event.get("body")).get('board_id')
    user_id = claims['username']

    # check that user owns the board
    response = user_boards_table.get_item(
        Key={
            'user_id': user_id,
            'board_id': board_id
        }
    )
    item = response.get('Item')
    if not item: raise Exception

    # get board
    response = board_cards_table.get_item(
        Key={
            'board_id': board_id,
        }
    )
    item = response.get('Item')
    if not item: raise Exception

    # send contents to user
    board_contents = item.get('board_contents')

    # load board document from json storage
    if board_contents.get('columns'):
        board_contents['columns'] = json.loads(board_contents.get('columns'))

    data = {'board_contents': board_contents}
    connection_id, callback_url = get_current_connection_info(event)
    send_to_connection(event.get("requestContext").get("routeKey"), data, connection_id, callback_url)
    return Status.OK

def update_board_contents_handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: return Status.forbidden

    dynamodb = boto3.resource('dynamodb')
    user_boards_table = dynamodb.Table('user_boards')
    board_cards_table = dynamodb.Table('board_cards')
    board_id = json.loads(event.get("body")).get('board_id')
    user_id = claims['username']
    board_contents = json.loads(event.get("body")).get('board_contents')

    # dump board document to string for storage
    if board_contents.get('columns'):
        board_contents['columns'] = json.dumps(board_contents.get('columns'))

    # check that user owns the board
    response = user_boards_table.get_item(
        Key={
            'user_id': user_id,
            'board_id': board_id
        }
    )
    item = response.get('Item')
    if not item: raise Exception

    # update board contents
    board_cards_table.update_item(
        Key={
            'board_id': board_id
        },
        UpdateExpression='SET board_contents = :board_contents',
        ExpressionAttributeValues={
            ':board_contents': board_contents
        }
    )

    # set updated_at attribute of board for user who made the update
    user_boards_table.update_item(
        Key={
            'user_id': user_id,
            'board_id': board_id
        },
        UpdateExpression='SET updated_at = :updated_at',
        ExpressionAttributeValues={
            ':updated_at': str(time.time())
        }
    )

    name_changed = False
    if board_contents.get('name') != item.get('board_name'):
        name_changed = True

    # load board document from string 
    if board_contents.get('columns'):
        board_contents['columns'] = json.loads(board_contents.get('columns'))

    # get all board owners
    response = user_boards_table.scan(
        FilterExpression=Attr('board_id').eq(board_id)
    )
    items = response['Items']

    for owner in items:
        curr_user_id = owner.get('user_id')

        # if name changed update board for each user
        if name_changed:
            user_boards_table.update_item(
                Key={
                    'user_id': curr_user_id,
                    'board_id': board_id
                },
                UpdateExpression='SET board_name = :board_name',
                ExpressionAttributeValues={
                    ':board_name': board_contents.get('name')
                }
            )

        # push new board contents to user if they are connected
        connection_id, callback_url = get_connection_info(curr_user_id)
        if connection_id:
            send_to_connection(Response.update_board_contents_response, {'board_contents': board_contents}, connection_id, callback_url)

        

    
    return Status.OK
    # return get_board_contents_handler(event, context)

def share_board_handler(event, context):
    # verify claims
    claims = verify_jwt(event, context)
    if not claims: return Status.forbidden

    dynamodb = boto3.resource('dynamodb')
    user_boards_table = dynamodb.Table('user_boards')
    board_id = json.loads(event.get("body")).get('board_id')
    share_with_username = json.loads(event.get("body")).get('shareWithUsername')
    user_id = claims['username']

    # check that not sharing with self
    if user_id == share_with_username:
        raise Exception

    # check that user owns the board
    response = user_boards_table.get_item(
        Key={
            'user_id': user_id,
            'board_id': board_id
        }
    )
    item = response.get('Item')
    print(item) # FIXME
    if not item: raise Exception

    # check that user to share with exists
    cognito = boto3.client('cognito-idp')

    try:
        response = cognito.admin_get_user(
            UserPoolId=user_pool_id,
            Username=share_with_username
        )
        print(response)
    except cognito.exceptions.UserNotFoundException:
        raise
    except Exception:
        raise

    # alter retreived record and insert it for person being shared with
    item['user_id'] = share_with_username
    user_boards_table.put_item(
        Item=item
    )

    # push user boards if they are connected
    connection_pool_table = dynamodb.Table('connection_pool')
    response = connection_pool_table.get_item(
        Key={
            'user_id': share_with_username,
        }
    )
    item = response.get('Item')
    if item:
        connection_id = item.get('connection_id')
        callback_url = item.get('callback_url')
        push_boards_to_connection(share_with_username, connection_id, callback_url)

    return Status.OK