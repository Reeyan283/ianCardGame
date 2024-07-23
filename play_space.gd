extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const CARD_SLOT = preload("res://board/card_slot_base.tscn")
const CARD_SIZE = Vector2(128, 128)

var card_selected = []
var card_slot_states = []

enum {
	Mulligan,
	DrawCard,
	PositionCard,
	PlayCard,
	DestroyCard,
	CardAura,
	InfluenceVoting,
	Apocalypse
}
var action_queue : Array = [DrawCard, PositionCard]
var card_queue: Array = [[],[]]

func _ready():
	var card_slot = CARD_SLOT.instantiate()
	card_slot.position = get_viewport().size * 0.4
	card_slot.size = CARD_SIZE
	$CardSlots.add_child(card_slot)
	card_slot_states.append(false)
	pass

func draw_card(input_card : String):
	var new_card = CARD_BASE.instantiate()
	
	new_card.card_name = input_card
	new_card.scale = CARD_SIZE/new_card.size
	new_card.position = $Deck.position - CARD_SIZE/2
	
	$CardsInHand.add_child(new_card)
	$CardsInHand.add_card(new_card, $CardsInHand.total_cards)
	
	new_card.position_in_hand(new_card.MovingToHand,new_card.index,$CardsInHand.total_cards)

func next_action():
	action_queue.remove_at(0)
	card_queue.remove_at(0)
	match action_queue:
		DrawCard:
			pass
		PlayCard:
			pass
