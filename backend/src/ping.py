from src.utils import Status, send_to_connection, get_current_connection_info

def handler(event, context):
    connection_id, callback_url = get_current_connection_info(event)
    send_to_connection('pong', 'pong', connection_id, callback_url)
    return Status.OK
