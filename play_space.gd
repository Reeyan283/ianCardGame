extends Node2D

const CARD_BASE = preload("res://cards/card_base.gd")
const PLAYER_HAND = preload("res://assets/cards/player_hand.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if Input.is_action_just_released("ui_select"):
		print("hi!")
		var new_card = CARD_BASE.new()
		new_card.card_name = "castle"
		new_card.position = get_global_mouse_position()
		print(new_card.position)
		$Cards.add_child(new_card)
		
