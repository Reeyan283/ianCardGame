extends MarginContainer

enum {
	Neutral,
	Primed,
	Receiving,
	
	TentativeHold,
	HasBuilding,
	Movable
}

var state = Neutral

var tentative_card: bool
var has_tentative_card: bool
var has_ruin: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.scale = size/$Background.texture.get_size()
	pass # Replace with function body.

func set_state(new_state):
	match new_state:
		Neutral, Primed, Movable:
			if has_ruin:
				$Background.texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/slots/ruin.png"))
			else:
				$Background.texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/slots/neutral.png"))
		Receiving:
			if has_ruin:
				$Background.texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/slots/ruin_receiving.png"))
			else:
				$Background.texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/slots/receiving.png"))
		TentativeHold, HasBuilding:
			$Background.texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/slots/blank.png"))
	state = new_state


func reset_state():
	match state:
		Primed, Receiving:
			set_state(Neutral)
		TentativeHold:
			pass

func set_primed(inc_neutral : bool, inc_ruins :bool):
	match state:
		Neutral:
			if (inc_neutral and not has_ruin) or (inc_ruins and has_ruin):
				set_state(Primed)

func set_receiving(inc_neutral : bool, inc_ruins :bool):
	match state:
		Primed:
			if (inc_neutral and not has_ruin) or (inc_ruins and has_ruin):
				set_state(Receiving)

func set_movable():
	if state == HasBuilding:
		set_state(Movable)
		var card = get_child(1)
		card.state = card.MovableInHand

func return_to_primed():
	match state:
		Receiving:
			set_state(Primed)
