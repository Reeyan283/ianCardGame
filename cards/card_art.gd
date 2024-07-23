class_name CardArt
extends MarginContainer

const this_scene: PackedScene = preload("res://cards/card_art.tscn")

@onready var card_database: Script = preload("res://cards/card_database.gd")

#Common Node Paths
#@onready var play_space_node = $"../../../"
#@onready var cards_node = play_space_node.find_child("Cards")
#@onready var hand_node = cards_node.find_child("Hand")

#properties
var card_name : String
var index : int
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

@onready var card_back = $CardBack
@onready var card = $Card

static func instance(card_name):
	var new_card_art: CardArt = this_scene.instantiate()
	new_card_art.card_name = card_name
	return new_card_art

# Called when the node enters the scene tree for the first time.
func _ready():
	var card_size = size
	$Card.texture = ImageTexture.create_from_image(Image.load_from_file(card_img_path))
	$Card.scale = card_size/$Card.texture.get_size()
	$CardBack.scale = card_size/$CardBack.texture.get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
