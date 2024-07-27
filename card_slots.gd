extends Node

const CARD_SLOT: PackedScene = preload("res://board/card_slot_base.tscn")

var card_slots_array: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func populate_slots(start_pos: Vector2, size: Vector2):
	for i in 7:
		var card_slot_row : Array = []
		for j in 7:
			var card_slot: Node = CARD_SLOT.instantiate()
			card_slot.position.x = start_pos.x + j * size.x
			card_slot.position.y = start_pos.y + i * size.y
			card_slot.size = size
			add_child(card_slot)
			card_slot_row.append(card_slot)
		card_slots_array.append(card_slot_row)

func reset_all():
	for i in 7:
		for j in 7:
			card_slots_array[i][j].reset_state()

func group_set_receiving(inc_neutral: bool, inc_ruins: bool):
	for i in 7:
		for j in 7:
			var slot = card_slots_array[i][j]
			if (slot.state == slot.Neutral and inc_neutral) or (slot.state == slot.Ruin and inc_ruins):
				slot.set_receiving()
