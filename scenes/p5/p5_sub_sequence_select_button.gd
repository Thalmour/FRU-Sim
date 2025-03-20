\
\
\
\
\
extends OptionButton
@onready var PRButton:OptionButton = get_node("/root/P5Main/Buttons/P5PRSelectButton")


func _ready() -> void :
	selected = Global.p5_selected_seq
	PRButton.visible = selected

func _on_item_selected(index: int) -> void :
	Global.p5_selected_seq = index
	PRButton.visible = selected
	
