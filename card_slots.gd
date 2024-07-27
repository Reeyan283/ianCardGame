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
