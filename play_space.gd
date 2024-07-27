extends Node2D

const CARD_BASE: PackedScene = preload("res://cards/card_base.tscn")
const CARD_SLOT: PackedScene = preload("res://board/card_slot_base.tscn")

const CARD_SIZE: Vector2 = Vector2(128, 128)
const DECK_SIZE: Vector2 = Vector2(200, 200)
const CARD_SLOT_SIZE: Vector2 = Vector2(100, 100)

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
	populate_slots(Vector2(420, 84), CARD_SLOT_SIZE)
	next_action()

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
	new_card.position = $DrawDeck.position - CARD_SIZE/2
	
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
