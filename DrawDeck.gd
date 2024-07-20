extends TextureButton

var draw_card_list: Array =  [
	"castle",
	"house",
	"house",
	"house",
	"house",
	"house",
	"house",
	"house"
]

var deck_size = draw_card_list.size()

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = $'../../'.CARD_SIZE/size
	pass # Replace with function body.


func _gui_input(event):
	if Input.is_action_just_released("ui_select"):
		if deck_size > 0:
			var drawn_card = $'../../'.draw_card(draw_card_list, deck_size)
			draw_card_list.erase(drawn_card)
			deck_size -= 1
			
			if deck_size <= 0:
				disabled = true
