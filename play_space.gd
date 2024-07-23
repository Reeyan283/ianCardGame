extends Node2D

const CARD_BASE: PackedScene = preload("res://cards/card_base.tscn")
const CARD_SLOT: PackedScene = preload("res://board/card_slot_base.tscn")

const CARD_SIZE: Vector2 = Vector2(128, 128)
const DECK_SIZE: Vector2 = Vector2(200, 200)
const CARD_SLOT_SIZE: Vector2 = Vector2(120, 120)

var card_selected = []
var card_slot_states = []

func _ready():

	populate_slots(Vector2(420, 84), CARD_SLOT_SIZE)
	
func populate_slots(start_pos: Vector2, size: Vector2):
	for i in 7:
		for j in 7:
			var card_slot: Node = CARD_SLOT.instantiate()
			card_slot.position.x = start_pos.x + j * size.x
			card_slot.position.y = start_pos.y + i * size.y
			card_slot.size = size
			$CardSlots.add_child(card_slot)
			card_slot_states.append(false)

func draw_card(input_card : String):
	var new_card = CARD_BASE.instantiate()
	
	new_card.card_name = input_card
	new_card.scale = CARD_SIZE/new_card.size
	new_card.position = $Deck.position - CARD_SIZE/2
	
	$Cards/Hand.add_child(new_card)
	$Cards/Hand.add_card(new_card, $Cards/Hand.total_cards)
	
	new_card.reposition(new_card.MovingLong,new_card.index,$Cards/Hand.total_cards)
