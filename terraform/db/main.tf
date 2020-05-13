resource "aws_dynamodb_table" "connection_pool" {
  name             = "connection_pool"
  hash_key         = "user_id"
  billing_mode     = "PAY_PER_REQUEST"
  
  attribute {
    name = "user_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "user_boards" {
  name             = "user_boards"
  hash_key         = "user_id"
  range_key        = "board_id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "board_id"
    type = "S"
  }

}

resource "aws_dynamodb_table" "board_cards" {
  name             = "board_cards"
  hash_key         = "board_id"
  billing_mode     = "PAY_PER_REQUEST"
  
  attribute {
    name = "board_id"
    type = "S"
  }
}