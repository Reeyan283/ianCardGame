extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const PLAYER_HAND = preload("res://assets/cards/player_hand.gd")
var player_hand = PLAYER_HAND.new()

const CARD_SIZE = Vector2(128, 128)

var card_selected = []
@onready var deck_size: int = player_hand.current_card_list.size()

@onready var hand_oval_center: Vector2 = Vector2(get_viewport().size.x, get_viewport().size.y) * Vector2(.5, 1.25)
@onready var hand_oval_major_radius: int = get_viewport().size.x * 0.5
@onready var hand_oval_minor_radius: int = get_viewport().size.y * 0.35

var hand_oval_angle: float = 0
var hand_oval_angle_vector: Vector2 = Vector2()
var hand_spread_angle: float = .18

var hand_card_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func draw_card(deck : Array, deck_size : int) -> String:
	hand_oval_angle = PI/2 + hand_spread_angle*(float(hand_card_count)/2 - hand_card_count)
	
	var new_card = CARD_BASE.instantiate()
	
	card_selected = 0
	new_card.card_name = deck[card_selected]
	new_card.scale = CARD_SIZE/new_card.size
	new_card.position = $Deck.position - CARD_SIZE/2
	
	
	hand_oval_angle_vector = Vector2(hand_oval_major_radius * cos(hand_oval_angle), -hand_oval_minor_radius * sin(hand_oval_angle))
	new_card.start_pos = $Deck.position - CARD_SIZE/2
	new_card.target_pos = hand_oval_center + hand_oval_angle_vector - Vector2(new_card.size.x *.5, new_card.size.y *.5)
	new_card.hand_pos = new_card.target_pos
	new_card.target_rot = (deg_to_rad(90) - hand_oval_angle)/3
	new_card.state = new_card.MoveDrawnCardToHand
	
	new_card.index = hand_card_count
	
	alignCards(get_node("Cards"), hand_spread_angle, true)

	$Cards.add_child(new_card)
	
	hand_card_count += 1
	
	return new_card.card_name
	
func alignCards(cards_node : Node, angle_iteration : float, new_card : bool):
	var card_count: int = cards_node.get_child_count()
	if not new_card:
		card_count -= 1
	var i = 0

	for card : MarginContainer in cards_node.get_children():
		var hand_oval_angle = PI/2 + angle_iteration * (float(card_count)/2 - i)
		hand_oval_angle_vector = Vector2(hand_oval_major_radius * cos(hand_oval_angle), -hand_oval_minor_radius * sin(hand_oval_angle))
		card.target_pos = hand_oval_center + hand_oval_angle_vector - Vector2(card.size.x *.5, card.size.y *.5)
		card.hand_pos = card.target_pos
		card.start_rot = card.rotation
		card.target_rot = (deg_to_rad(90) - hand_oval_angle)/3
		
		card.index = i
		
		i+=1
		
		if card.state == card.InHand:
			card.state = card.OrganiseHand
			card.start_pos = card.position
		elif card.state == card.MoveDrawnCardToHand:
			card.start_pos = card.target_pos - ((card.target_pos - card.position)/(1-card.t))
			
		card.setup_flag = true
			
