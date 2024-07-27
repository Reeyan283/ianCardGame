extends MarginContainer

@onready var card_database: Script = preload("res://cards/card_database.gd")
@onready var card_img_script: Script = preload("res://cards/card_art.gd")

#Common Node Paths
@onready var play_space = $/root/PlaySpace
@onready var hand = play_space.find_child("Hand")

# Card States
enum{
	Neutral,
	
	InHand,
	InMouseInHand,
	FocusingInHand,
	MovingToHand,
	MovingFromHand,
	MovingInHand,
	
	InPlay,
	MovableInPlay,
	InMouseInPlay,
	MovingInPlay,
	MovingToPlay,
	MovingFromPlay
}

#properties
var card_name : String
var index : int
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

@onready var original_scale: Vector2 = scale

#Hand Positioning
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
@onready var card_offset = play_space.CARD_SIZE * .5

var t: float = 0 
@onready var hand_line: float = get_viewport().size.y * 0.73

var move_short_time: float = 0.2
var move_long_time: float = 0.7
var focus_time: float = 0.25
var scale_time = 0.1

var in_top: bool = true
var is_drawing: bool = true

var state = Neutral

var card_img = MarginContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	card_img = card_img_script.instance(card_name)
	add_child(card_img, true, 1)
	$Focus.scale = card_img.size/$Focus.get_size()

	


func _physics_process(delta):
	match state:
		InMouseInHand:
			rotation = 0
			position = get_viewport().get_mouse_position() - card_offset
			if t <= 1:
				scale = start_scale * (1-t) + target_scale * t
				t += delta/float(scale_time)
			else:
				scale = target_scale
			if position.y < hand_line and not in_top:
				hand.set_state(hand.InMouseTop, 20)
				hand.align_cards()
				in_top = true
			if position.y > hand_line and in_top:
				hand.set_state(hand.InMouseBottom, 20)
				in_top = false
			if not in_top and position_to_index(get_viewport().get_mouse_position()) != hand.gap_index:
				hand.gap_index = position_to_index(get_viewport().get_mouse_position())
				hand.align_cards()
		
		FocusingInHand, MovingToPlay, MovingFromPlay:
			move(delta,focus_time)
		
		MovingToHand:
			if is_drawing and card_img.card_back.visible:
				target_scale.x = -original_scale.x
				if t >= 0.5:
					start_scale.x = -original_scale.x
					target_scale.x = original_scale.x
					card_img.card_back.visible = false
					is_drawing = false
			if position.y > hand_line and in_top:
				hand.align_cards()
				in_top = false
			move(delta, move_long_time)
		
		MovingFromHand:
			if is_drawing and not card_img.card_back.visible.visible:
				target_scale.x = -original_scale.x
				if t >= 0.5:
					start_scale.x = -original_scale.x
					target_scale.x = original_scale.x
					card_img.card_back.visible = true
					is_drawing = false
			if position.y > hand_line and in_top:
				hand.align_cards()
				in_top = false
			move(delta, move_long_time)
		
		MovingInHand, MovingInPlay:
			move(delta,move_short_time)
		
		InMouseInPlay:
			position = get_viewport().get_mouse_position() - card_offset

func position_in_hand(newState,slot_num,total_slots):
	hand_circle_angle = PI/2 + HAND_SPREAD_ANGLE * (float(total_slots-1)/2 - slot_num)
	hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
	target_pos = hand_circle_center + hand_circle_angle_vector - card_offset
	target_rot = PI/2 - hand_circle_angle
	target_scale = original_scale
	match state:
		Neutral, InHand, MovingInHand:
			t = 0
			start_pos = position
			start_rot = rotation
			start_scale = scale
			state = newState
		FocusingInHand:
			t=0
			start_pos = position
			start_rot = rotation
			start_scale = scale
			target_rot = 0
			target_pos.y = get_viewport().size.y - play_space.CARD_SIZE.y * 1.75
			target_pos.x = (hand_circle_center + hand_circle_angle_vector + card_offset).x
			target_scale = focus_scale

func _on_focus_mouse_entered():
	match state:
		MovingInHand, InHand:
			if hand.state == hand.Neutral:
				hand.set_state(hand.Focusing, index)
				hand.align_cards()
				position_in_hand(FocusingInHand,index, hand.total_cards)
				target_rot = 0
				target_pos.y = get_viewport().size.y - play_space.CARD_SIZE.y * 1.75
				target_scale = focus_scale
				state = FocusingInHand
				t=0
		InPlay, MovableInPlay:
			pass

func _on_focus_mouse_exited():
	match state:
		FocusingInHand:
			state = Neutral
			hand.set_neutral()
			hand.align_cards()
		InPlay, MovableInPlay:
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
		match state:
			InMouseInHand, MovingToHand, MovingInHand:
				state = InHand
			MovingFromHand:
				pass
			MovableInPlay, InMouseInPlay, MovingInPlay, MovingToPlay:
				state = InPlay
			MovingFromPlay:
				pass

func _input(event):
	match state:
		FocusingInHand:
			if event.is_action_pressed("ui_select"):
				hand.remove_card(self)
				hand.set_state(hand.InMouseBottom, index)
				hand.align_cards()
				start_scale = scale
				target_scale = original_scale
				t=0
				state = InMouseInHand
		InMouseInHand:
			if event.is_action_released("ui_select"):
				var nearest_slot_dist = find_nearest_slot()[0]
				var nearest_slot = find_nearest_slot()[1]
				
				if nearest_slot_dist < 72 and nearest_slot.get_child_count() == 1:
					position = find_nearest_slot()[1].position
					hand.set_neutral()
					scale = play_space.CARD_SLOT_SIZE/size
					target_pos = nearest_slot.position
					reparent(nearest_slot)
					t=0
					state = InPlay

				elif in_top:
					hand.add_card(self, hand.total_cards)
					state = Neutral
					position_in_hand(MovingToHand, index, hand.total_cards)
					hand.set_neutral()
				else:
					hand.add_card(self, hand.gap_index)
					state = Neutral
					position_in_hand(MovingInHand, index, hand.total_cards)
					hand.set_neutral()

func position_to_index(pos : Vector2) -> int:
	var deviation = (PI/2 + hand_circle_center.angle_to_point(pos))/HAND_SPREAD_ANGLE
	if hand.total_cards % 2 == 1:
		deviation += 0.5
	var gap_index = round((hand.total_cards)/2 + deviation)
	if gap_index < 0:
		return 0
	elif gap_index > hand.total_cards:
		return hand.total_cards
	else:
		return gap_index

func find_nearest_slot():
	var adjusted_pos = position + card_offset
	var nearest_slot = INF
	var smallest_dist = INF

	for card_slot in play_space.find_child("CardSlots").get_children():
		var card_slot_pos = card_slot.position + card_offset
		var dist = sqrt(((card_slot_pos.x - adjusted_pos.x) * (card_slot_pos.x - adjusted_pos.x)) + ((card_slot_pos.y - adjusted_pos.y) * (card_slot_pos.y - adjusted_pos.y)))

		if dist < smallest_dist:
			smallest_dist = dist
			nearest_slot = card_slot
		
	return [smallest_dist, nearest_slot]
