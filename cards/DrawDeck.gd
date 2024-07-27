extends TextureButton

@onready var play_space = $'../'

var draw_card_list: Array =  [
	"castle",
	"castle",
	"castle",
	"house",
	"house",
	"house",
	"house",
	"house",
	"house",
	"house",
	"house",
	"house"
]

var deck_size = draw_card_list.size()
var cards_to_draw: int = 7
var drawing_active: bool = false

func _ready():
	scale = play_space.CARD_SIZE/size
	draw_card_list.shuffle()
	pass


func _gui_input(_event):
	if Input.is_action_just_released("ui_select"):
		if deck_size > 0 and cards_to_draw > 0 and drawing_active:
			play_space.draw_card(draw_card_list[0])
			draw_card_list.remove_at(0)
			deck_size -= 1
			cards_to_draw -= 1
			if deck_size <= 0:
				disabled = true
			if cards_to_draw <= 0:
				drawing_active = false
				cards_to_draw = 1
				$'Highlight'.visible = false
				$'../'.next_action()
