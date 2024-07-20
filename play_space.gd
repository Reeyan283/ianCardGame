extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const PLAYER_HAND = preload("res://assets/cards/player_hand.gd")
var player_hand = PLAYER_HAND.new()


const CARD_SIZE = Vector2(128, 128)

var card_selected = []
@onready var deck_size: int = player_hand.current_card_list.size()

@onready var hand_circle_center: Vector2 = Vector2(get_viewport().size.x, get_viewport().size.y) * Vector2(0.5, 2.75)
@onready var hand_circle_radius: int = get_viewport().size.x * 1

var hand_circle_angle: float = 0
var hand_circle_angle_vector: Vector2 = Vector2()
const HAND_SPREAD_ANGLE: float = .07

var hand_card_count = 0

func _ready():
	pass

func draw_card(deck : Array, deck_size : int) -> String:
	hand_circle_angle = PI/2 - HAND_SPREAD_ANGLE*(float(hand_card_count)/2)
	
	var new_card = CARD_BASE.instantiate()
	
	card_selected = 0
	new_card.card_name = deck[card_selected]
	new_card.scale = CARD_SIZE/new_card.size
	new_card.position = $Deck.position - CARD_SIZE
	
	
	hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
	new_card.start_pos = $Deck.position - CARD_SIZE/2
	new_card.target_pos = hand_circle_center + hand_circle_angle_vector - new_card.size.x * Vector2(.5,.5)
	new_card.hand_pos = new_card.target_pos
	new_card.target_rot = PI/2 - hand_circle_angle
	new_card.state = new_card.MoveDrawnCardToHand
	
	new_card.index = hand_card_count
	
	alignCards(get_node("Cards"), HAND_SPREAD_ANGLE, true, 0.55)

	$Cards.add_child(new_card)
	
	hand_card_count += 1
	
	return new_card.card_name
	
func alignCards(cards_node : Node, angle_iteration : float, new_card : bool, delay : float):
	var card_count: int = cards_node.get_child_count()
	if not new_card:
		card_count -= 1
	var i = 0

	for card : MarginContainer in cards_node.get_children():
		var hand_circle_angle = PI/2 + angle_iteration * (float(card_count)/2 - i)
		hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
		card.target_pos = hand_circle_center + hand_circle_angle_vector - card.size.x * Vector2(.5,.5)
		card.hand_pos = card.target_pos
		card.start_rot = card.rotation
		card.target_rot = PI/2 - hand_circle_angle
		
		card.index = i
		i+=1
		
		if card.state == card.InHand:
			card.state = card.OrganiseHand
			card.start_pos = card.position
			if card.freeze_time <= 0:
				card.freeze_time = delay
		elif card.state == card.MoveDrawnCardToHand:
			card.start_pos = card.target_pos - ((card.target_pos - card.position)/(1-card.t))
			
		card.setup_flag = true
			
