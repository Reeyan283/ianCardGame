extends Node

@onready var card_database: Script = preload("res://assets/cards/card_database.gd")
var card_name = "castle"
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", "house", ".png")

@onready var orignal_scale: Vector2 = scale

func _ready():

	var card_size = size

	$GameBoard.texture = ImageTexture.create_from_image(Image.load_from_file(card_img_path))
	$GameBoard.scale = card_size/$Card.texture.get_size(
