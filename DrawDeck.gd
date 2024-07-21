extends TextureButton

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


func _ready():
	scale = $'../../'.CARD_SIZE/size
	draw_card_list.shuffle()
	pass


func _gui_input(_event):
	if Input.is_action_just_released("ui_select"):
		if deck_size > 0:
			var drawn_card = $'../../'.draw_card(draw_card_list)
			draw_card_list.erase(drawn_card)
			deck_size -= 1
			
			if deck_size <= 0:
				disabled = true
