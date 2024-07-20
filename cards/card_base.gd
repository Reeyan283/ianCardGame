extends MarginContainer

@onready var card_database: Script = preload("res://assets/cards/card_database.gd")
var card_name = "castle"
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

@onready var orignal_scale: Vector2 = scale

var start_pos = 0
var target_pos = 0
var start_rot = 0
var target_rot = 0
var t = 0 
var draw_time: float = 1
var organize_time: float = .2
var focus_time: float = 0.2

# Card States
enum{
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	OrganiseHand
}

var state = InHand

# Called when the node enters the scene tree for the first time.
func _ready():

	var card_size = size

	$Card.texture = ImageTexture.create_from_image(Image.load_from_file(card_img_path))
	$Card.scale = card_size/$Card.texture.get_size()
	$Focus.scale = card_size/$Focus.get_size()
	$CardBack.scale = card_size/$CardBack.texture.get_size()


var setup_flag: bool = true
var start_scale: Vector2 = Vector2()
var hand_pos: Vector2 = Vector2()
var focus_size: float = 2
var focus_organize_flag: bool = true
var hand_card_count: int = 0
var index = 0
	
func _physics_process(delta):
	match state:
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			pass
		FocusInHand:
			if setup_flag:
				setup()
			if t <=1:
				position = start_pos.lerp(target_pos, t)
				rotation = start_rot * (1-t) + target_rot * t
				scale = start_scale * (1-t) + orignal_scale * focus_size * t
					
				t += delta/float(focus_time)
				
				if focus_organize_flag:
					focus_organize_flag = false
					hand_card_count = get_node("../../Cards").get_child_count()
					
					for i in hand_card_count:
						if i < index:
							align_neighbor_card(i, false, 1)
						elif i > index:
							align_neighbor_card(i, true, 1)
				
			else:
				position = target_pos
				rotation = target_rot
				scale = orignal_scale * focus_size
				
		MoveDrawnCardToHand:
			if t <=1:
				position = start_pos.lerp(target_pos, t)
				rotation = start_rot * (1-t) + target_rot*t
				scale.x = orignal_scale.x * abs(2*t - 1)
				
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false
				
				t += delta/float(draw_time)
			else:
				position = target_pos
				rotation = target_rot
				scale.x = orignal_scale.x
				state = InHand
				t = 0

		OrganiseHand:
			if setup_flag:
				setup()
			if t <=1:
				position = start_pos.lerp(target_pos, t)
				rotation = start_rot * (1-t) + target_rot*t
				scale = start_scale * (1-t) + orignal_scale*t
				t += delta/float(organize_time)
			else:
				position = target_pos
				rotation = target_rot
				scale = orignal_scale
				state = InHand
				t = 0
				
func align_neighbor_card(card_index : int, right : bool, spread_factor: float):
	var card = $'../'.get_child(card_index)
	if right:
		card.target_pos = card.hand_pos + spread_factor * Vector2(65, 0)
	else:
		card.target_pos = card.hand_pos - spread_factor * Vector2(65, 0)
	
	card.setup_flag = true
	card.state = OrganiseHand

func setup():
	start_pos = position
	start_rot = rotation
	start_scale = scale
	t = 0
	setup_flag = false

func _on_focus_mouse_entered():
	match state:
		InHand, OrganiseHand:
			setup_flag = true
			target_rot = 0
			target_pos = hand_pos

			target_pos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y * focus_size * 1.57

			state = FocusInHand


func _on_focus_mouse_exited():
	match state:
		FocusInHand:
			target_pos = hand_pos
			state = OrganiseHand
			$'../../'.alignCards(get_node("../../Cards"), $'../../'.HAND_SPREAD_ANGLE, false)
			setup_flag = true
			focus_organize_flag = true
