extends MarginContainer

enum {
	Neutral,
	Receiving,
	Ruin,
	RuinReceiving,
	TentativeHold,
	HasBuilding,
	Movable
}

var state = Neutral

var tentative_card
var has_tentative_card

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.scale = size/$Background.texture.get_size()
	pass # Replace with function body.

func set_state(new_state):
	match new_state:
		Neutral:
			state = Neutral
		Receiving:
			state = Receiving
		Ruin:
			state = Neutral
		RuinReceiving:
			state = RuinReceiving
		TentativeHold:
			state = TentativeHold
		HasBuilding:
			state = HasBuilding
		Movable:
			state = Movable


func reset_state():
	match state:
		Receiving:
			set_state(Neutral)
		RuinReceiving:
			set_state(Ruin)
		TentativeHold:
			pass

func set_receiving():
	match state:
		Neutral:
			set_state(Receiving)
		Ruin:
			set_state(RuinReceiving)

func set_movable():
	if state == HasBuilding:
		set_state(Movable)
		var card = get_child(1)
		card.state = card.MovableInHand
