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
var move_short_time: float = 0.2
var move_long_time: float = 1
var focus_time: float = 0.25
var shift_line: float = 0.7
var shift_flag: bool = true
var drawing_flag: bool = true

# Card States
enum{
	Neutral,
	InHand,
	InPlay,
	InMouse,
	Focusing,
	MovingLong,
	MovingShort
}

var state = Neutral

# Called when the node enters the scene tree for the first time.
func _ready():

	var card_size = size

	$Card.texture = ImageTexture.create_from_image(Image.load_from_file(card_img_path))
	$Card.scale = card_size/$Card.texture.get_size()
	$Focus.scale = card_size/$Focus.get_size()
	$CardBack.scale = card_size/$CardBack.texture.get_size()

func _physics_process(delta):
	match state:
		Neutral:
			pass
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			rotation = 0
			position = get_viewport().get_mouse_position() - $'../../'.CARD_SIZE.x * Vector2(0.5,0.5)
			scale = original_scale
			if position.y < get_viewport().size.y * shift_line and not shift_flag:
				$"../../Cards".remove_slot(slot_num)
				$"../../Cards".align_cards()
				shift_flag = true
		Focusing:
			move(delta,focus_time)
		MovingLong:
			if drawing_flag and $CardBack.visible:
				target_scale.x = -original_scale.x
				if t >= 0.5:
					start_scale.x = -original_scale.x
					target_scale.x = original_scale.x
					$CardBack.visible = false
					$"../../Cards".align_cards()
					drawing_flag = false
			if position.y > get_viewport().size.y * shift_line and shift_flag:
				$"../../Cards".align_cards()
				shift_flag = false
			move(delta, move_long_time)
		MovingShort:
			move(delta,move_short_time)
		

func reposition(newState):
	hand_circle_angle = PI/2 + HAND_SPREAD_ANGLE * (float($"../../Cards".total_slots + 1)/2 - slot_num)
	hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
	target_pos = hand_circle_center + hand_circle_angle_vector - $'../../'.CARD_SIZE.x * Vector2(0.5,0.5)
	target_rot = PI/2 - hand_circle_angle
	target_scale = original_scale
	match state:
		Neutral, InHand, MovingShort, Focusing:
			t = 0
			start_pos = position
			start_rot = rotation
			start_scale = scale
			state = newState

func _on_focus_mouse_entered():
	match state:
		InHand, MovingShort:
			$"../../Cards".add_slot(slot_num)
			$"../../Cards".align_cards()
			state = Focusing
			target_rot = 0
			target_pos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y * 1.75
			target_pos.x += $'../../'.CARD_SIZE.x * 0.5
			target_scale = focus_scale

func _on_focus_mouse_exited():
	match state:
		Focusing:
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
		if state != Focusing:
			state = InHand
		t = 2

func _input(event):
	match state:
		Focusing:
			if event.is_action_pressed("ui_select"):
				target_scale = original_scale
				t=0
				$"../../Cards".remove_slot(slot_num)
				$"../../Cards".align_cards()
				state = InMouse
		InMouse:
			if event.is_action_released("ui_select"):
				t=0
				if shift_flag:
					var keep_size = slot_num
					$"../../Cards".add_slot(slot_num-1)
					slot_num = keep_size
				shift_flag = true
				state = Neutral
				reposition(MovingLong)
