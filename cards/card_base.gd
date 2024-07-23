extends MarginContainer

@onready var card_database: Script = preload("res://assets/cards/card_database.gd")
var card_name : String
var index : int
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")


@onready var hand_circle_center: Vector2 = Vector2(get_viewport().size.x, get_viewport().size.y) * Vector2(0.5, 3.65)
@onready var hand_circle_radius: int = get_viewport().size.x * 1.5
var hand_circle_angle: float = 0
var hand_circle_angle_vector: Vector2 = Vector2()
const HAND_SPREAD_ANGLE: float = .047

var start_pos: Vector2
var target_pos: Vector2
var start_rot: float
var target_rot: float
@onready var original_scale: Vector2 = scale
var start_scale: Vector2
@onready var target_scale: Vector2 = original_scale
@onready var focus_scale: Vector2 = original_scale*2
@onready var card_offset = $'../../'.CARD_SIZE.x * Vector2(0.5,0.5)

var t: float = 0 
var move_short_time: float = 0.2
var move_long_time: float = 0.8
var focus_time: float = 0.25
var scale_time = 0.1
@onready var hand_line: float = get_viewport().size.y * 0.7
var in_top: bool = true
var is_drawing: bool = true
var in_hand: bool = true

# Card States
enum{
	Neutral,
	InPlay,
	InMouse,
	Focusing,
	MovingToHand,
	MovingFromHand,
	MovingInHand
}
var state = Neutral

func _ready():
	var card_size = size
	$Card.texture = ImageTexture.create_from_image(Image.load_from_file(card_img_path))
	$Card.scale = card_size/$Card.texture.get_size()
	$Focus.scale = card_size/$Focus.get_size()
	$CardBack.scale = card_size/$CardBack.texture.get_size()

func _physics_process(delta):
	match state:
		Neutral, InPlay:
			pass
		InMouse:
			rotation = 0
			position = get_viewport().get_mouse_position() - card_offset
			if t <= 1:
				scale = start_scale * (1-t) + target_scale * t
				t += delta/float(scale_time)
			else:
				scale = target_scale
			if in_hand == true:
				if position.y < hand_line and not in_top:
					$"../../CardsInHand".set_state($"../../CardsInHand".InMouseTop, 20)
					$"../../CardsInHand".align_cards()
					in_top = true
				if position.y > hand_line and in_top:
					$"../../CardsInHand".set_state($"../../CardsInHand".InMouseBottom, 20)
					in_top = false
				if not in_top and position_to_index(get_viewport().get_mouse_position()) != $"../../CardsInHand".gap_index:
					$"../../CardsInHand".gap_index = position_to_index(get_viewport().get_mouse_position())
					$"../../CardsInHand".align_cards()
		Focusing:
			move(delta,focus_time)
		MovingToHand:
			if is_drawing and $CardBack.visible:
				target_scale.x = -original_scale.x
				if t >= 0.5:
					start_scale.x = -original_scale.x
					target_scale.x = original_scale.x
					$CardBack.visible = false
					is_drawing = false
			if position.y > hand_line and in_top:
				$"../../CardsInHand".align_cards()
				in_top = false
			move(delta, move_long_time)
		MovingInHand:
			move(delta,move_short_time)
		

func position_in_hand(newState,slot_num,total_slots):
	hand_circle_angle = PI/2 + HAND_SPREAD_ANGLE * (float(total_slots-1)/2 - slot_num)
	hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
	target_pos = hand_circle_center + hand_circle_angle_vector - card_offset
	target_rot = PI/2 - hand_circle_angle
	target_scale = original_scale
	match state:
		Neutral, MovingInHand:
			t = 0
			start_pos = position
			start_rot = rotation
			start_scale = scale
			state = newState
		Focusing:
			t=0
			start_pos = position
			start_rot = rotation
			start_scale = scale
			target_rot = 0
			target_pos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y * 1.75
			target_pos.x = (hand_circle_center + hand_circle_angle_vector).x + $'../../'.CARD_SIZE.x * 0.5
			target_scale = focus_scale

func _on_focus_mouse_entered():
	match state:
		MovingInHand, Neutral:
			if $"../../CardsInHand".state == $"../../CardsInHand".Neutral:
				$"../../CardsInHand".set_state($"../../CardsInHand".Focusing, index)
				$"../../CardsInHand".align_cards()
				position_in_hand(Focusing,index, $"../../CardsInHand".total_cards)
				target_rot = 0
				target_pos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y * 1.75
				target_scale = focus_scale
				state = Focusing
				t=0
		InPlay:
			pass

func _on_focus_mouse_exited():
	match state:
		Focusing:
			state = Neutral
			$"../../CardsInHand".set_neutral()
			$"../../CardsInHand".align_cards()
		InPlay:
			pass

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
			state = Neutral

func _input(event):
	match state:
		Focusing:
			if event.is_action_pressed("ui_select"):
				$"../../CardsInHand".remove_card(self)
				$"../../CardsInHand".set_state($"../../CardsInHand".InMouseBottom, index)
				$"../../CardsInHand".align_cards()
				start_scale = scale
				target_scale = original_scale
				t=0
				state = InMouse
		InMouse:
			if event.is_action_released("ui_select"):
				var nearest_slot_dist = find_nearest_slot()[0]
				var nearest_slot = find_nearest_slot()[1]
				print(nearest_slot.get_child_count())
				if nearest_slot_dist < 100 and nearest_slot.get_child_count() == 1:
					position = find_nearest_slot()[1].position
					state = InPlay
					$"../../CardsInHand".set_neutral()
				elif in_top:
					$"../../CardsInHand".add_card(self,$"../../CardsInHand".total_cards)
					state = Neutral
					position_in_hand(MovingToHand,index,$"../../CardsInHand".total_cards)
					$"../../CardsInHand".set_neutral()
				else:
					$"../../CardsInHand".add_card(self,$"../../CardsInHand".gap_index)
					state = Neutral
					position_in_hand(MovingInHand,index,$"../../CardsInHand".total_cards)
					$"../../CardsInHand".set_neutral()

func position_to_index(pos : Vector2) -> int:
	var deviation = (PI/2 + hand_circle_center.angle_to_point(pos))/HAND_SPREAD_ANGLE
	if $"../../CardsInHand".total_cards % 2 == 1:
		deviation += 0.5
	var gap_index = round(($"../../CardsInHand".total_cards)/2 + deviation)
	if gap_index < 0:
		return 0
	elif gap_index > $"../../CardsInHand".total_cards:
		return $"../../CardsInHand".total_cards
	else:
		return gap_index

func find_nearest_slot():
	var adjusted_pos = position + $'../../'.CARD_SIZE * .5
	var nearest_slot = INF
	var largest_dist = -INF
	var largest_slot_pos = []
	for card_slot in $'../../'.find_child("CardSlots").get_children():
		var card_slot_pos = card_slot.position + $'../../'.CARD_SIZE * .5
		var dist = sqrt(((card_slot_pos.x - adjusted_pos.x) * (card_slot_pos.x - adjusted_pos.x)) + ((card_slot_pos.y - adjusted_pos.y) * (card_slot_pos.y - adjusted_pos.y)))
		
		if dist > largest_dist:
			largest_dist = dist
			nearest_slot = card_slot
			largest_slot_pos = card_slot_pos
		
	return [largest_dist, nearest_slot]
