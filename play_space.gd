extends Node2D

const CARD_BASE: PackedScene = preload("res://cards/card_base.tscn")

const CARD_SIZE: Vector2 = Vector2(128, 128)
const DECK_SIZE: Vector2 = Vector2(200, 200)
const CARD_SLOT_SIZE: Vector2 = Vector2(100, 100)

enum {
	SetupPhase,
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
	$CardSlots.populate_slots(Vector2(420, 84), CARD_SLOT_SIZE)
	next_action()

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
