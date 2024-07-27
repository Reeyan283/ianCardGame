extends MarginContainer

enum {
	Neutral,
	Primed,
	Receiving,
	
	Ruin,
	RuinPrimed,
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
		Neutral, Primed, Movable:
			pass
		Receiving:
			pass
		Ruin, RuinPrimed:
			pass
		RuinReceiving:
			pass
		TentativeHold, HasBuilding:
			pass
	state = new_state


func reset_state():
	match state:
		Primed, Receiving:
			set_state(Neutral)
		RuinPrimed, RuinReceiving:
			set_state(Ruin)
		TentativeHold:
			pass

func set_primed(inc_neutral : bool, inc_ruins :bool):
	match state:
		Primed:
			if inc_neutral:
				set_state(Primed)
		RuinPrimed:
			if inc_ruins:
				set_state(RuinPrimed)

func set_receiving(inc_neutral : bool, inc_ruins :bool):
	match state:
		Primed:
			if inc_neutral:
				set_state(Receiving)
		RuinPrimed:
			if inc_ruins:
				set_state(RuinReceiving)

func set_movable():
	if state == HasBuilding:
		set_state(Movable)
		var card = get_child(1)
		card.state = card.MovableInHand

func return_to_primed():
	match state:
		Receiving:
			set_state(Primed)
		RuinReceiving:
			set_state(RuinPrimed)
