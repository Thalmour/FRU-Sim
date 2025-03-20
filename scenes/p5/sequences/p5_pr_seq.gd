\
\
\
\
\
extends Node

const WINGS_LIFETIME: = 0.5
const DARK_WINGS_ANGLE_OFFSET_DEG = 135.0
const DARK_WINGS_COLOR: = Color.DARK_VIOLET
const LIGHT_WINGS_COLOR: = Color.GOLD

const WINGS_TB_RADIUS: = 13.0
const WINGS_TB_LIFETIME: = 0.3
const WINGS_TB_COLOR: = Color.WEB_PURPLE

const TOWER_LIFETIME = 9.7
const TOWER_POS: = {"s": Vector2(-16.6, 0), "nw": Vector2(8.3, -14.38), "ne": Vector2(8.3, 14.38)}

@onready var p5_pr_anim: AnimationPlayer = % P5PRAnim
@onready var cast_bar: CastBar = % CastBar
@onready var ground_aoe_controller: GroundAoeController = % GroundAoEController
@onready var oracle_boss: Node3D = % OracleBoss
@onready var oracle: Oracle = % Oracle
@onready var fail_list: FailList = % FailList
@onready var hide_bots_check_button: CheckButton = % HideBotsCheckButton
@onready var encounter_controller: EncounterController = % EncounterController
@onready var light_wing_anim: AnimationPlayer = % LightWingAnim
@onready var dark_wing_anim: AnimationPlayer = % DarkWingAnim
@onready var light_wing_effect: Node3D = % LightWingEffect
@onready var dark_wing_effect: Node3D = % DarkWingEffect
@onready var pr_strat = SavedVariables.save_data["settings"]["p5_pr_strat"]


var party: Dictionary
var arena_rotation_deg: float
var ne_tower: bool
var dark_first: bool
var towers: Dictionary

func start_sequence(new_party: Dictionary) -> void :
	assert (new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["circle", "wide_cone", "pr_tower"])
	party = new_party
	hide_bots_check_button.set_bots_visible()
	hide_bots_check_button.disabled = true

	arena_rotation_deg = 120.0 * randi_range(0, 2)
	ne_tower = randi() % 2 == 0
	dark_first = true #randi() % 2 == 0

	p5_pr_anim.play("p5_pr_seq")







func cast_paradise():
	cast_bar.cast("Paradise Regained", 3.7)




func move_pre_pos():
	move_party(PRPos.PRE_POS)




func finish_cast():
	oracle.play_slash()




func spawn_tower_1():
	var tower_pos = TOWER_POS["s"].rotated(deg_to_rad(arena_rotation_deg))
	towers["s"] = ground_aoe_controller.spawn_pr_tower(tower_pos, TOWER_LIFETIME)
	towers["s"].set_bodies_required(2)




func cast_wings():
	cast_bar.cast("Wings of Dark and Light", 6.8)





func spawn_tower_2():
	var t2_key = "ne" if ne_tower else "nw"
	var tower_pos = TOWER_POS[t2_key].rotated(deg_to_rad(arena_rotation_deg))
	towers[t2_key] = ground_aoe_controller.spawn_pr_tower(tower_pos, TOWER_LIFETIME)
	towers[t2_key].set_bodies_required(2)

	if dark_first:
		dark_wing_anim.play("dark_wing_glow", -1, 0.5)
	else:
		light_wing_anim.play("light_wing_glow", -1, 0.5)




func move_pos_1():
	if dark_first:
		if pr_strat ==  0:
			move_party_pr_rotated(PRPos.DARK_POS_1_IT)
		else :
			move_party_pr_rotated(PRPos.DARK_POS_1)
	else:
		if pr_strat ==  0:
			move_party_pr_rotated(PRPos.LIGHT_POS_1_IT)
		else :
			move_party_pr_rotated(PRPos.LIGHT_POS_1)




func play_wing_anim_2():
	if dark_first:
		light_wing_anim.play("light_wing_glow", -1, 0.5)
	else:
		dark_wing_anim.play("dark_wing_glow", -1, 0.5)




func spawn_tower_3():
	var t3_key = "nw" if ne_tower else "ne"
	var tower_pos = TOWER_POS[t3_key].rotated(deg_to_rad(arena_rotation_deg))
	towers[t3_key] = ground_aoe_controller.spawn_pr_tower(tower_pos, TOWER_LIFETIME)
	towers[t3_key].set_bodies_required(2)



func boss_face_t1():
	face_boss_toward("t1")





func tower_1_hit():
	light_wing_anim.stop()
	dark_wing_anim.stop()
	light_wing_effect.hide()
	dark_wing_effect.hide()

	tower_hit("s")


	var nearest_targets: Array = get_nearest_target_list(Vector2(0, 0), 8)
	if dark_first:
		var tar: Vector2 = v2(party["t1"].global_position).rotated(deg_to_rad(DARK_WINGS_ANGLE_OFFSET_DEG))
		ground_aoe_controller.spawn_wide_cone(Vector2(0, 0), tar, WINGS_LIFETIME, DARK_WINGS_COLOR, 
			[1, 1, "Wings of Dark and Light (Cleave)", [party["t1"]]])
		ground_aoe_controller.spawn_circle(v2(party[nearest_targets[0]].global_position), WINGS_TB_RADIUS, 
			WINGS_TB_LIFETIME, WINGS_TB_COLOR, [1, 1, "Wings of Dark and Light (Near Tank Buster)", [party["t2"]]])
	else:
		var tar: Vector2 = v2(party["t1"].global_position)
		ground_aoe_controller.spawn_wide_cone(Vector2(0, 0), tar, WINGS_LIFETIME, LIGHT_WINGS_COLOR, 
			[1, 1, "Wings of Dark and Light (Cleave)", [party["t1"]]])
		ground_aoe_controller.spawn_circle(v2(party[nearest_targets[7]].global_position), WINGS_TB_RADIUS, 
			WINGS_TB_LIFETIME, WINGS_TB_COLOR, [1, 1, "Wings of Dark and Light (Far Tank Buster)", [party["t2"]]])




func move_pos_2():
	if dark_first:
		if pr_strat ==  0:
			move_party_pr_rotated(PRPos.DARK_POS_2_IT)
		else:
			move_party_pr_rotated(PRPos.DARK_POS_2)
	else:
		if pr_strat ==  0:
			move_party_pr_rotated(PRPos.LIGHT_POS_2_IT)
		else:
			move_party_pr_rotated(PRPos.LIGHT_POS_2)




func boss_face_t2():
	face_boss_toward("t2")





func tower_2_hit():
	if ne_tower:
		tower_hit("ne")
	else:
		tower_hit("nw")


	var nearest_targets: Array = get_nearest_target_list(Vector2(0, 0), 8)
	if dark_first:
		var tar: Vector2 = v2(party["t2"].global_position)
		ground_aoe_controller.spawn_wide_cone(Vector2(0, 0), tar, WINGS_LIFETIME, LIGHT_WINGS_COLOR, 
			[1, 1, "Wings of Dark and Light (Cleave)", [party["t2"]]])
		ground_aoe_controller.spawn_circle(v2(party[nearest_targets[7]].global_position), WINGS_TB_RADIUS, 
			WINGS_TB_LIFETIME, WINGS_TB_COLOR, [1, 1, "Wings of Dark and Light (Far Tank Buster)", [party["t1"]]])
	else:
		var tar: Vector2 = v2(party["t2"].global_position).rotated(deg_to_rad(DARK_WINGS_ANGLE_OFFSET_DEG))
		ground_aoe_controller.spawn_wide_cone(Vector2(0, 0), tar, WINGS_LIFETIME, DARK_WINGS_COLOR, 
			[1, 1, "Wings of Dark and Light (Cleave)", [party["t2"]]])
		ground_aoe_controller.spawn_circle(v2(party[nearest_targets[0]].global_position), WINGS_TB_RADIUS, 
			WINGS_TB_LIFETIME, WINGS_TB_COLOR, [1, 1, "Wings of Dark and Light (Near Tank Buster)", [party["t1"]]])




func tower_3_hit():
	if ne_tower:
		tower_hit("nw")
	else:
		tower_hit("ne")





func play_ps_seq():
	var tween = get_tree().create_tween()
	tween.tween_property(oracle_boss, "rotation", Vector3(0, 0, 0), 0.6)
	encounter_controller.play_sequence_by_index(2)





func tower_hit(tower_key) -> void :
	if towers[tower_key].soaked != LRTower.SoakState.SOAKED:
		if towers[tower_key].soaked == LRTower.SoakState.OVER:
			fail_list.add_fail("Too many players soaked tower.")
		elif towers[tower_key].soaked == LRTower.SoakState.UNDER:
			fail_list.add_fail("Not enough players soaked tower.")
	towers[tower_key].queue_free()


func face_boss_toward(target_key):
	var curr_rota = oracle_boss.rotation
	oracle_boss.look_at(party[target_key].global_position)
	var tar_rota_y = oracle_boss.rotation.y + deg_to_rad(90)
	oracle_boss.rotation = curr_rota

	var tween = get_tree().create_tween()
	tween.tween_property(oracle_boss, "rotation", Vector3(0, tar_rota_y, 0), 0.6)



func get_nearest_target_list(source_pos: Vector2, number_of_targets) -> Array:

	var dist_list: = []
	var keys_list: = []
	for key in party:
		dist_list.append(v2(party[key].global_position).distance_squared_to(source_pos))
		keys_list.append(key)

	assert (dist_list.size() == keys_list.size())
	var n = dist_list.size()
	for i in range(n):
		for j in range(0, n - i - 1):
			if dist_list[j] > dist_list[j + 1]:

				var tmp = dist_list[j]
				dist_list[j] = dist_list[j + 1]
				dist_list[j + 1] = tmp

				var tmp_key = keys_list[j]
				keys_list[j] = keys_list[j + 1]
				keys_list[j + 1] = tmp_key

	keys_list.resize(number_of_targets)
	return keys_list


func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)



func move_party(pos: Dictionary) -> void :
	for key: String in pos:
		party[key].move_to(pos[key])



func move_party_pr_rotated(pos: Dictionary) -> void :
	for key: String in pos:
		party[key].move_to(pos[key].rotated(deg_to_rad(arena_rotation_deg)))
