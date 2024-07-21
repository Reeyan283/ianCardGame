extends MarginContainer

@onready var card_database: Script = preload("res://assets/cards/card_database.gd")
var card_name : String
var slot_num : int
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

@onready var original_scale: Vector2 = scale

@onready var hand_circle_center: Vector2 = Vector2(get_viewport().size.x, get_viewport().size.y) * Vector2(0.5, 3.65)
@onready var hand_circle_radius: int = get_viewport().size.x * 1.5

var hand_circle_angle: float = 0
var hand_circle_angle_vector: Vector2 = Vector2()
const HAND_SPREAD_ANGLE: float = .047

var start_pos: Vector2
var target_pos: Vector2
var start_rot: float
var target_rot: float
var start_scale: Vector2
@onready var target_scale: Vector2 = original_scale
@onready var focus_scale: Vector2 = original_scale*2

var t: float = 0 
var draw_time: float = 1
var organize_time: float = 0.2
var focus_time: float = 0.25
var draw_shift_delay: float = 0.55
var draw_shift_flag: bool = true

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

func _physics_process(delta):
	match state:
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			pass
		FocusInHand:
			move(delta,focus_time)
		MoveDrawnCardToHand:
			move(delta, draw_time)
			if t <=1:
				if $CardBack.visible:
					target_scale.x = -original_scale.x
					if t >= 0.5:
						start_scale.x = -original_scale.x
						target_scale.x = original_scale.x
						$CardBack.visible = false
				if t >= draw_shift_delay and draw_shift_flag:
					$"../../Cards".align_cards()
					draw_shift_flag = false
		OrganiseHand:
			move(delta,organize_time)

func reposition(newState):
	hand_circle_angle = PI/2 + HAND_SPREAD_ANGLE * (float($"../../Cards".total_slots + 1)/2 - slot_num)
	hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
	target_pos = hand_circle_center + hand_circle_angle_vector - $'../../'.CARD_SIZE.x * Vector2(0.5,0.5)
	target_rot = PI/2 - hand_circle_angle
	target_scale = original_scale
	match state:
		InHand, OrganiseHand, FocusInHand:
			t = 0
			start_pos = position
			start_rot = rotation
			start_scale = scale
			state = newState
	
func _on_focus_mouse_entered():
	match state:
		InHand, OrganiseHand:
			$"../../Cards".add_slot(slot_num)
			$"../../Cards".align_cards()
			state = FocusInHand
			target_rot = 0
			target_pos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y * 1.75
			target_pos.x += $'../../'.CARD_SIZE.x * 0.5
			target_scale = focus_scale

func _on_focus_mouse_exited():
	$"../../Cards".remove_slot(slot_num)
	$"../../Cards".align_cards()

func move(delta, time : float):
	if t <=1:
		position = start_pos.lerp(target_pos, t)
		rotation = start_rot * (1-t) + target_rot*t
		scale = start_scale * (1-t) + target_scale * t
		t += delta/float(time)
	else:
		position = target_pos
		rotation = target_rot
		scale = target_scale
		state = InHand
		t = 0
