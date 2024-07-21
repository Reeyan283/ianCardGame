extends Node
var total_cards: int = 0
enum {
	Neutral,
	InMouseBottom,
	InMouseTop,
	Focusing
}
var state = Neutral
var gap_index = 20

func align_cards():
	var card_node = get_children()
	for c in card_node:
		if c.index >= 0:
			match state:
				Neutral, InMouseTop:
					c.reposition(c.MovingShort,c.index,total_cards)
				Focusing, InMouseBottom:
					if c.index >= gap_index:
						c.reposition(c.MovingShort,c.index + 1,total_cards + 1)
					elif c.index >= 0:
						c.reposition(c.MovingShort,c.index,total_cards + 1)

func add_card(card: Node, pos : int):
	var card_node = get_children()
	for c in card_node:
		if c.index >= pos:
			c.index += 1
	card.index = pos
	total_cards += 1

func remove_card(card: Node):
	var card_node = get_children()
	total_cards -= 1
	for c in card_node:
		if c.index > card.index:
			c.index -= 1
	card.index = -1

func set_neutral():
	state = Neutral
	gap_index = 20

func set_state(new_state, new_index):
	state = new_state
	gap_index = new_index
