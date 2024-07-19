extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const PLAYER_HAND = preload("res://assets/cards/player_hand.gd")
var player_hand = PLAYER_HAND.new()

const CARD_SIZE = Vector2(175, 175)

var card_selected = []
@onready var deck_size = player_hand.current_card_list.size()

@onready var hand_oval_center: Vector2 = Vector2(get_viewport().size.x, get_viewport().size.y) * Vector2(.5, 1.25)
@onready var hand_oval_major_radius: int = get_viewport().size.x * 0.45
@onready var hand_oval_minor_radius: int = get_viewport().size.y * 0.4
var hand_oval_angle: float = deg_to_rad(90) -0.5
var hand_oval_angle_vector = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func draw_card(deck : Array, deck_size : int) -> String:
	var new_card = CARD_BASE.instantiate()
	card_selected = randi() % deck_size
	
	new_card.card_name = deck[card_selected]
	hand_oval_angle_vector = Vector2(hand_oval_major_radius * cos(hand_oval_angle), -hand_oval_minor_radius * sin(hand_oval_angle))
	new_card.position = hand_oval_center + hand_oval_angle_vector - Vector2(new_card.size.x *.5, new_card.size.y *.5)
	new_card.scale *= CARD_SIZE/new_card.size
	new_card.rotation = (deg_to_rad(90) - hand_oval_angle)/3
	$Cards.add_child(new_card)
	hand_oval_angle += 0.25

	return new_card.card_name
