extends Node

@onready var card_slots = $/root/PlaySpace/CardSlots

enum {
	Neutral,
	InMouseBottom,
	InMouseTop,
	Focusing
}

var state = Neutral
var total_cards: int = 0
var gap_index: int
var positioning_active: bool = false

func align_cards():
	var cards_node = get_children()
	for c in cards_node:
		if c.index >= 0:
			match state:
				Neutral, InMouseTop:
					c.position_in_hand(c.MovingInHand,c.index,total_cards)
				Focusing, InMouseBottom:
					if c.index >= gap_index:
						c.position_in_hand(c.MovingInHand,c.index + 1,total_cards + 1)
					elif c.index >= 0:
						c.position_in_hand(c.MovingInHand,c.index,total_cards + 1)

func add_card(card: Node, pos : int):
	var cards_node = get_children()
	for c in cards_node:
		if c.index >= pos:
			c.index += 1
	card.index = pos
	total_cards += 1

func remove_card(card: Node):
	var cards_node = get_children()
	total_cards -= 1
	for c in cards_node:
		if c.index > card.index:
			c.index -= 1
	card.index = -1

func set_neutral():
	state = Neutral

func set_state(new_state, new_index):
	state = new_state
	gap_index = new_index

func highlight_all():
	var cards_node = get_children()
	for c in cards_node:
		if c.index >= 0:
			c.get_child(1).visible = true

func enter_mouse(card):
	remove_card(card)
	set_state(InMouseBottom, card.index)
	align_cards()
	if positioning_active:
		card_slots.group_receiving(true,false)
