extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const CARD_SLOT = preload("res://board/card_slot_base.tscn")
const CARD_SIZE = Vector2(128, 128)

var card_selected = []
var card_slot_states = []

enum {
	TurnStart,
	Mulligan,
	DrawCard,
	PositionCard,
	PlayCard,
	DestroyCard,
	CardAura,
	InfluenceVoting,
	Apocalypse,
	TurnEnd
}
var action_queue : Array = [TurnStart, DrawCard, PositionCard, TurnEnd]
var next_action_queue : Array = [TurnStart, DrawCard, PositionCard, TurnEnd]
var card_queue: Array = [[],[],[],[]]
var next_card_queue: Array = [[],[],[],[]]

func _ready():
	var card_slot = CARD_SLOT.instantiate()
	card_slot.position = get_viewport().size * 0.4
	card_slot.size = CARD_SIZE
	$CardSlots.add_child(card_slot)
	card_slot_states.append(false)
	next_action()
	pass

func draw_card(input_card : String):
	var new_card = CARD_BASE.instantiate()
	
	new_card.card_name = input_card
	new_card.scale = CARD_SIZE/new_card.size
	new_card.position = $DrawDeck.position
	
	$Hand.add_child(new_card)
	$Hand.add_card(new_card, $Hand.total_cards)
	
	new_card.position_in_hand(new_card.MovingToHand,new_card.index,$Hand.total_cards)

func next_action():
	action_queue.remove_at(0)
	card_queue.remove_at(0)
	match action_queue[0]:
		DrawCard:
			$DrawDeck.drawing_active = true
			$DrawDeck/Highlight.visible = true
		PositionCard:
			$Hand.highlight_all()
		TurnEnd:
			action_queue = next_action_queue
			card_queue = next_card_queue
			next_action()
