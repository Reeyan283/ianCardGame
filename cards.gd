extends Node
var total_slots: int = 0

func align_cards():
	var card_node = get_children()
	for card in card_node:
		card.reposition(card.MovingShort)

func add_slot(pos : int):
	print_debug("add " + str(pos))
	var card_node = get_children()
	total_slots += 1
	for card in card_node:
		if card.slot_num > pos:
			card.slot_num += 1

func remove_slot(pos: int):
	print_debug("remove " + str(pos))
	var card_node = get_children()
	total_slots = total_slots - 1
	for card in card_node:
		if card.slot_num > pos:
			card.slot_num -= 1
