extends MarginContainer




# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.scale = size/$Background.texture.get_size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
