extends MarginContainer

enum {
	Neutral,
	Recieving,
	Ruin,
	RuinRecieving,
	TentativeHold,
	HasBuilding
}


# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.scale = size/$Background.texture.get_size()
	pass # Replace with function body.

