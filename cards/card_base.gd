extends MarginContainer

@onready var card_database = preload("res://assets/cards/card_database.gd")
var card_name = "castle"
@onready var card_info = card_database.DATA.get(card_database[card_name])
@onready var card_img_path = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

# Called when the node enters the scene tree for the first time.
func _ready():

	var card_size = size
	
	var card = Sprite2D.new()
	card.texture = ImageTexture.create_from_image(Image.load_from_file(card_img_path))
	card.scale *= card_size/card.texture.get_size()
	card.centered = false
	
	add_child(card)
	
	print(card_img_path)
	print(get_child_count())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
