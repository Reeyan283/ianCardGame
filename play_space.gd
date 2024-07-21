extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const CARD_SLOT = preload("res://board/card_slot_base.tscn")
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
const CARD_SIZE = Vector2(128, 128)

var card_selected = []

<<<<<<< Updated upstream
@onready var hand_circle_center: Vector2 = Vector2(get_viewport().size.x, get_viewport().size.y) * Vector2(0.5, 3.65)
@onready var hand_circle_radius: int = get_viewport().size.x * 1.5

var hand_circle_angle: float = 0
var hand_circle_angle_vector: Vector2 = Vector2()
const HAND_SPREAD_ANGLE: float = .047

=======
>>>>>>> Stashed changes
var card_slot_states = []
func _ready():
	var card_slot = CARD_SLOT.instantiate()
	card_slot.position = get_viewport().size * 0.4
	card_slot.size = CARD_SIZE
	$CardSlots.add_child(card_slot)
	card_slot_states.append(false)
	pass

func draw_card(deck : Array) -> String:
	var cards_node: Node = get_node("Cards/Hand")
	var card_count: int = cards_node.get_child_count()
	hand_circle_angle = PI/2 - HAND_SPREAD_ANGLE*(float(card_count)/2)
	
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
	
	new_card.index = card_count
	
	alignCards(true, 0.55)

	$Cards/Hand.add_child(new_card)
	
	
	return new_card.card_name
	
func alignCards(new_card : bool, delay : float):
	var cards_node: Node = get_node("Cards/Hand")
	var card_count: int = cards_node.get_child_count()
	if not new_card:
		card_count -= 1
	var i = 0

	for card : MarginContainer in cards_node.get_children():
		hand_circle_angle = PI/2 + HAND_SPREAD_ANGLE * (float(card_count)/2 - i)
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
		elif card.state == card.MoveDrawnCardToHand:
			card.start_pos = card.target_pos - ((card.target_pos - card.position)/(1-card.t))
			
		card.setup_flag = true
			
