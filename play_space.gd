extends Node2D

const CARD_BASE = preload("res://cards/card_base.tscn")
const CARD_SIZE = Vector2(128, 128)

var card_selected = []

func _ready():
	pass

func draw_card(input_card : String):
	var new_card = CARD_BASE.instantiate()
	
	new_card.card_name = input_card
	new_card.scale = CARD_SIZE/new_card.size
	new_card.position = $Deck.position - CARD_SIZE/2
	
	$Cards.add_child(new_card)
	$Cards.add_card(new_card, $Cards.total_cards)
	
	new_card.reposition(new_card.MovingLong,new_card.index,$Cards.total_cards)
