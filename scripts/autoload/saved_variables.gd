\
\
\
\
\
extends Node

signal keybind_changed(keybinds: Dictionary)

const CONFIG_FILE_PATH = "user://config.cfg"

var config_file: ConfigFile
var save_data: Dictionary = {
	"settings": {
		"player_role": 0, 
		"screen_res": Vector2i(1600, 900), 
		"screen_pos": null, 
		"maximized": false, 
		"camera_distance": 22, 
		"mouse_sens": 1.0, 
		"x_sens": 1.0, 
		"y_sens": 1.0, 
		"invert_y": false, 
		"selected_seq": 0, 
		"p2_lr_strat": 0, 
		"p3_sa_strat": 0, 
		"p3_sa_swap": 0, 
		"p3_ur_strat": 0, 
		"p4_dd_strat": 0, 
		"p4_dd_am_strat": 0, 
		"p4_dd_dance_strat": 0, 
		"p4_ct_strat": 0, 
		"p4_ct_am_strat": 0, 
		"p4_ct_aero_plant": false, 
		"p5_pr_strat": 0,
		"pt_list_order": ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"], 
		"pt_list_player_top": true
	}, 
	"keybinds": {
		"ab1_sprint": KEY_1, 
		"ab2_arms": KEY_2, 
		"ab3_dash": KEY_3, 
		"reset": KEY_R, 
		"move_ui": KEY_ALT
	}, 
	"waymarks": {
		"active": "preset_1", 
		"custom_1": {
			"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR, 
			"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR, 
		}, 
		"custom_2": {
			"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR, 
			"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR, 
		}
	}, 
	"ui_positions": {}, 
	"ui_scales": {}
}


func _ready() -> void :
	GameEvents.variable_saved.connect(on_variable_saved)
	GameEvents.variable_removed.connect(on_variable_removed)
	config_file = ConfigFile.new()
	load_save_file()
	set_defaults()
	set_keybinds()
	save()


func get_data(category: String, key: String) -> Variant:
	return save_data[category][key]


func has_data(category: String, key: String) -> bool:
	if save_data.has(category):
		return save_data[category].has(key)
	return false



func load_save_file() -> void :
	var _err: = config_file.load(CONFIG_FILE_PATH)

	for section in config_file.get_sections():
		for key in config_file.get_section_keys(section):
			if not save_data.has(section):
				save_data[section] = {}

			save_data[section][key] = config_file.get_value(section, key)


func save() -> void :
	var err: = config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		print("Error saving config file: ", err)


func set_defaults() -> void :
	for section: String in save_data:
		for key: String in save_data[section]:
			config_file.set_value(section, key, save_data[section][key])


func on_variable_saved(section: String, key: String, value: Variant) -> void :
	if not save_data.has(section):
		save_data[section] = {}

	save_data[section][key] = value
	config_file.set_value(section, key, value)
	save()
	if section == "keybinds":
		set_keybinds()


func on_variable_removed(section: String, key: String) -> void :
	if save_data.has(section):
		save_data[section].erase(key)

	if config_file.has_section_key(section, key):
		config_file.erase_section_key(section, key)

	save()


func set_keybinds() -> void :
	for key: String in save_data["keybinds"]:
		var new_key_event: = InputEventKey.new()
		new_key_event.set_keycode(save_data["keybinds"][key])
		if !InputMap.action_has_event(key, new_key_event):
			InputMap.action_erase_events(key)
			InputMap.action_add_event(key, new_key_event)

	keybind_changed.emit(save_data["keybinds"])


func get_keybinds() -> Dictionary:
	return save_data["keybinds"]


func get_screen_res() -> Vector2i:
	return save_data["settings"]["screen_res"]


func get_screen_pos():
	return save_data["settings"]["screen_pos"]
