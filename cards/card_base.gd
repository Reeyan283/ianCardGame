extends MarginContainer

@onready var card_database: Script = preload("res://assets/cards/card_database.gd")
@onready var play_space = $'../../../'

var card_name : String
@onready var card_info: Array = card_database.DATA.get(card_database[card_name])
@onready var card_img_path: String = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

@onready var orignal_scale: Vector2 = scale

var start_pos: Vector2 = Vector2()
var target_pos: Vector2 = Vector2()
var start_rot: float = 0
var target_rot: float = 0
var t: float = 0 
var draw_time: float = 1
var organize_time: float = 0.2
var focus_time: float = 0.25
var freeze_time: float = 0
var in_mouse_time: float = 0.1
var draw_shift_delay: float = 0.55

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
var draw_shift_flag: bool = true
var start_scale: Vector2 = Vector2()
var hand_pos: Vector2 = Vector2()
var focus_size: float = 2
var focus_organize_flag: bool = true
var hand_card_count: int = 0
var card_select_flag: bool = true
var index = 0

func _physics_process(delta):
	match state:
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			if setup_flag:
				setup()
			if t <=1:
				position = start_pos.lerp(get_global_mouse_position() - play_space.CARD_SIZE * .5, t)
				rotation = start_rot * (1-t) + 0*t
				scale = start_scale * (1-t) + orignal_scale * t
				
				increment_t(delta,in_mouse_time)
			else:
				position = get_global_mouse_position() - play_space.CARD_SIZE * .5
				rotation = target_rot
		FocusInHand:
			if setup_flag:
				setup()
			if t <=1:
				position = start_pos.lerp(target_pos, t)
				rotation = start_rot * (1-t) + target_rot * t
				scale = start_scale * (1-t) + orignal_scale * focus_size * t
					
				increment_t(delta,focus_time)
				
				if focus_organize_flag:
					focus_organize_flag = false
					hand_card_count = get_parent().get_child_count()
					
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
			if setup_flag:
				setup()
			if t <=1:
				position = start_pos.lerp(target_pos, t)
				rotation = start_rot * (1-t) + target_rot*t
				scale.x = orignal_scale.x * abs(2*t - 1)
				
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false
				
				increment_t(delta,draw_time)
				
				#if t >= draw_shift_delay and draw_shift_flag:
				#	play_space.alignCards(true, 1)
				#	draw_shift_flag = false
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
				increment_t(delta,organize_time)
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
	
	card.freeze_time = 0
	card.setup_flag = true
	
	if not card.state == MoveDrawnCardToHand:
		card.state = OrganiseHand

func find_nearest_slot():
	var adjusted_pos = position + play_space.CARD_SIZE * .5
	var nearest_slot = INF
	var largest_dist = -INF
	var largest_slot_pos = []
	for card_slot in play_space.find_child("CardSlots").get_children():
		var card_slot_pos = card_slot.position + play_space.CARD_SIZE * .5
		var dist = sqrt(((card_slot_pos.x - adjusted_pos.x) * (card_slot_pos.x - adjusted_pos.x)) + ((card_slot_pos.y - adjusted_pos.y) * (card_slot_pos.y - adjusted_pos.y)))
		
		if dist > largest_dist:
			largest_dist = dist
			nearest_slot = card_slot
			largest_slot_pos = card_slot_pos
		
	return [largest_dist, nearest_slot]
func setup():
	start_pos = position
	start_rot = rotation
	start_scale = scale
	t = 0
	setup_flag = false
	
func _input(event):
	match state:
		FocusInHand, InMouse:
			if event.is_action_pressed("ui_select"):
				if card_select_flag:
					state = InMouse
					setup_flag = true
					card_select_flag = false
			elif event.is_action_released("ui_select"):
				if not card_select_flag:
					var nearest_slot_dist = find_nearest_slot()[0]
					var nearest_slot = find_nearest_slot()[1]
					print(nearest_slot.get_child_count())
					if nearest_slot_dist < 100 and nearest_slot.get_child_count() == 1:
						position = find_nearest_slot()[1].position
						state = InPlay
						reparent(find_nearest_slot()[1])
						
						play_space.alignCards(false, 0)
						setup_flag = true
						focus_organize_flag = true
						card_select_flag = true
					else:
						target_pos = hand_pos
						state = OrganiseHand
						play_space.alignCards(false, 0)
						setup_flag = true
						focus_organize_flag = true
						card_select_flag = true
			
		InPlay:
			pass

func _on_focus_mouse_entered():
	match state:
		InHand, OrganiseHand:
			setup_flag = true
			target_rot = 0
			target_pos = hand_pos
			freeze_time = 0
			target_pos.y = get_viewport().size.y - play_space.CARD_SIZE.y * focus_size * .75

			state = FocusInHand


func _on_focus_mouse_exited():
	match state:
		FocusInHand:
			target_pos = hand_pos
			state = OrganiseHand
			play_space.alignCards(false, 0)
			setup_flag = true
			focus_organize_flag = true
			
func increment_t(delta, time : float):
	if freeze_time > 0:
		freeze_time -= delta
	else:
		t += delta/float(time)
<<<<<<< Updated upstream
=======
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
				$"../../Cards".remove_card(self)
				$"../../Cards".set_state($"../../Cards".InMouseBottom, index)
				$"../../Cards".align_cards()
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
					$"../../Cards".set_neutral()
				elif in_top_flag:
					$"../../Cards".add_card(self,$"../../Cards".total_cards)
					state = Neutral
					reposition(MovingLong,index,$"../../Cards".total_cards)
					$"../../Cards".set_neutral()
				else:
					$"../../Cards".add_card(self,$"../../Cards".gap_index)
					state = Neutral
					reposition(MovingShort,index,$"../../Cards".total_cards)
					$"../../Cards".set_neutral()

func position_to_slot(pos : Vector2) -> int:
	var deviation = (PI/2 + hand_circle_center.angle_to_point(pos))/HAND_SPREAD_ANGLE
	if $"../../Cards".total_cards % 2 == 1:
		deviation += 0.5
	var gap_index = round(($"../../Cards".total_cards)/2 + deviation)
	if gap_index < 0:
		return 0
	elif gap_index > $"../../Cards".total_cards:
		return $"../../Cards".total_cards
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
>>>>>>> Stashed changes
