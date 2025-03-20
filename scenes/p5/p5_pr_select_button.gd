extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.selected = SavedVariables.save_data["settings"]["p5_pr_strat"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_item_selected(index: int) -> void:
	GameEvents.emit_variable_saved("settings", "p5_pr_strat", index)
