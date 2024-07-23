extends MarginContainer

@onready var card_database: Script = preload("res://cards/card_database.gd")
@onready var card_img_script: Script = preload("res://cards/card_art.gd")

#Common Node Paths
@onready var play_space_node = $"../../../"
@onready var cards_node = play_space_node.find_child("Cards")
@onready var hand_node = cards_node.find_child("Hand")

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

#properties
var card_name : String
var index : int
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

@onready var original_scale: Vector2 = scale

#Deck Positioning
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
var shift_line: float = 0.65

var move_short_time: float = 0.2
var move_long_time: float = 0.8
var focus_time: float = 0.25
var shrink_time = 0.1

var in_top_flag: bool = true
var drawing_flag: bool = true

var state = Neutral

var card_img = MarginContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	card_img = card_img_script.instance(card_name)
	add_child(card_img, true, 1)
	$Focus.scale = card_img.size/$Focus.get_size()

	


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
			position = get_viewport().get_mouse_position() - play_space_node.CARD_SIZE.x * Vector2(0.5,0.5)
			if t <= 1:
				scale = start_scale * (1-t) + target_scale * t
				t += delta/float(shrink_time)
			else:
				scale = target_scale
			
			if position.y < get_viewport().size.y * shift_line and not in_top_flag:
				hand_node.set_state(hand_node.InMouseTop, 20)
				hand_node.align_cards()
				in_top_flag = true
			if position.y > get_viewport().size.y * shift_line and in_top_flag:
				hand_node.set_state(hand_node.InMouseBottom, 20)
				in_top_flag = false
			if not in_top_flag and position_to_slot(get_viewport().get_mouse_position()) != hand_node.gap_index:
				hand_node.gap_index = position_to_slot(get_viewport().get_mouse_position())
				hand_node.align_cards()
		Focusing:
			move(delta,focus_time)
		MovingLong:
			if drawing_flag and card_img.card_back.visible:
				target_scale.x = -original_scale.x
				if t >= 0.5:
					start_scale.x = -original_scale.x
					target_scale.x = original_scale.x
					card_img.card_back.visible = false
					drawing_flag = false
			if position.y > get_viewport().size.y * shift_line and in_top_flag:
				hand_node.align_cards()
				in_top_flag = false
			move(delta, move_long_time)
		MovingShort:
			move(delta,move_short_time)
		

func reposition(newState,slot_num,total_slots):
	hand_circle_angle = PI/2 + HAND_SPREAD_ANGLE * (float(total_slots-1)/2 - slot_num)
	hand_circle_angle_vector = hand_circle_radius * Vector2(cos(hand_circle_angle), -sin(hand_circle_angle))
	target_pos = hand_circle_center + hand_circle_angle_vector - play_space_node.CARD_SIZE.x * Vector2(0.5,0.5)
	target_rot = PI/2 - hand_circle_angle
	target_scale = original_scale
	match state:
		Neutral, InHand, MovingShort:
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
			target_pos.y = get_viewport().size.y - play_space_node.CARD_SIZE.y * 1.75
			target_pos.x = (hand_circle_center + hand_circle_angle_vector).x + play_space_node.CARD_SIZE.x * 0.5
			target_scale = focus_scale

func _on_focus_mouse_entered():
	print("HI")
	match state:
		InHand, MovingShort, Neutral:
			if hand_node.state == hand_node.Neutral:
				hand_node.set_state(hand_node.Focusing, index)
				hand_node.align_cards()
				reposition(Focusing,index, hand_node.total_cards)
				target_rot = 0
				target_pos.y = get_viewport().size.y - play_space_node.CARD_SIZE.y * 1.75
				target_scale = focus_scale
				state = Focusing
				t=0

func _on_focus_mouse_exited():
	match state:
		Focusing:
			state = Neutral
			hand_node.set_neutral()
			hand_node.align_cards()

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
				hand_node.remove_card(self)
				hand_node.set_state(hand_node.InMouseBottom, index)
				hand_node.align_cards()
				start_scale = scale
				target_scale = original_scale
				t=0
				state = InMouse
		InMouse:
			if event.is_action_released("ui_select"):
				var nearest_slot_dist = find_nearest_slot()[0]
				var nearest_slot = find_nearest_slot()[1]
				
				if nearest_slot_dist < 100 and nearest_slot.get_child_count() == 1:
					position = find_nearest_slot()[1].position
					size = play_space_node.CARD_SLOT_SIZE
					scale = Vector2(1, 1)
					state = InPlay
					hand_node.set_neutral()
					reparent(nearest_slot)
				elif in_top_flag:
					hand_node.add_card(self, hand_node.total_cards)
					state = Neutral
					reposition(MovingLong, index, hand_node.total_cards)
					hand_node.set_neutral()
				else:
					hand_node.add_card(self, hand_node.gap_index)
					state = Neutral
					reposition(MovingShort, index, hand_node.total_cards)
					hand_node.set_neutral()

func position_to_slot(pos : Vector2) -> int:
	var deviation = (PI/2 + hand_circle_center.angle_to_point(pos))/HAND_SPREAD_ANGLE
	if hand_node.total_cards % 2 == 1:
		deviation += 0.5
	var gap_index = round((hand_node.total_cards)/2 + deviation)
	if gap_index < 0:
		return 0
	elif gap_index > hand_node.total_cards:
		return hand_node.total_cards
	else:
		return gap_index

func find_nearest_slot():
	var adjusted_pos = position + play_space_node.CARD_SIZE * .5
	var nearest_slot = INF
	var smallest_dist = INF

	for card_slot in play_space_node.find_child("CardSlots").get_children():
		var card_slot_pos = card_slot.position + play_space_node.CARD_SIZE * .5
		var dist = sqrt(((card_slot_pos.x - adjusted_pos.x) * (card_slot_pos.x - adjusted_pos.x)) + ((card_slot_pos.y - adjusted_pos.y) * (card_slot_pos.y - adjusted_pos.y)))

		if dist < smallest_dist:
			smallest_dist = dist
			nearest_slot = card_slot
		
	return [smallest_dist, nearest_slot]
