extends Control

# this is the temporary faux-json for data storage on weapon behaviours
var weapon = preload("res://src/technical/abilities/json_weapon_styles.gd")

var base_cooldown_texture_scale = Vector2(0.12, 0.12)

# initial game time settings
# easy difficulty has longer time
var base_game_time_minutes_easy_difficulty = 30
# normal difficulty has standardised time
var base_game_time_minutes_normal_difficulty = 20
# hard difficulty has less time
var base_game_time_minutes_hard_difficulty = 10

enum GameDifficulty{
	EASY,
	NORMAL,
	HARD
}

var is_time_passing = false

var chosen_difficulty = GameDifficulty.NORMAL

# NOTE: damage removes time, (skill use removes time?)

var current_game_time_minute = 0
var current_game_time_second = 0

var current_weapon_cooldown_ui_graphic

onready var weapon_cooldown = $CooldownRadialHolder/WeaponCooldownRadial
onready var ability1_cooldown = $CooldownRadialHolder/Ability1CooldownRadial
onready var ability2_cooldown = $CooldownRadialHolder/Ability2CooldownRadial
onready var ability3_cooldown = $CooldownRadialHolder/Ability3CooldownRadial

onready var weapon_cooldown_segment_timer = $CooldownRadialHolder/WeaponCooldownRadial/WeaponSegmentTimer
onready var ability1_cooldown_segment_timer = $CooldownRadialHolder/Ability1CooldownRadial/Ability1SegmentTimer
onready var ability2_cooldown_segment_timer = $CooldownRadialHolder/Ability2CooldownRadial/Ability2SegmentTimer
onready var ability3_cooldown_segment_timer = $CooldownRadialHolder/Ability3CooldownRadial/Ability3SegmentTimer

onready var decor_strip = $CooldownRadialHolder/CooldownDecorStripe

onready var weapon_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Weapon/WeaponSpriteAnchor
onready var ability1_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Ability1/AbilitySprite1Anchor
onready var ability2_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Ability2/AbilitySprite2Anchor
onready var ability3_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Ability3/AbilitySprite3Anchor

onready var game_time_label = $ClockLabel
onready var game_timer = $GameTimer_Seconds

###############################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	set_game_time()
	set_game_timer()
	set_cooldown_texture_positions_and_dimensions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	# testing values
#	weapon_cooldown.value += 1
#	ability1_cooldown.value += 1
#	ability2_cooldown.value += 1


###############################################################################


# initialise game time before setting game timer
func set_game_time():
	# set game seconds to 0
	current_game_time_second = 0
	# set game minutes based on chosen difficulty
	match chosen_difficulty:
		GameDifficulty.EASY:
			current_game_time_minute = base_game_time_minutes_easy_difficulty
		GameDifficulty.NORMAL:
			current_game_time_minute = base_game_time_minutes_normal_difficulty
		GameDifficulty.HARD:
			current_game_time_minute = base_game_time_minutes_hard_difficulty


func set_game_timer():
	game_timer.wait_time = 1.0
	game_timer.start()


func set_cooldown_texture_positions_and_dimensions():
	set_scale_and_center_radial(weapon_sprite, weapon_cooldown)
	set_scale_and_center_radial(ability1_sprite, ability1_cooldown)
	set_scale_and_center_radial(ability2_sprite, ability2_cooldown)
	set_scale_and_center_radial(ability3_sprite, ability3_cooldown)
	# account for scale adjustment when getting rect size
	var half_rect_y = (weapon_cooldown.rect_size.y * weapon_cooldown.rect_scale.y) / 8
	# set decor strip to be positioned with radial cooldown timers
	decor_strip.rect_position.y =\
	 weapon_cooldown.rect_position.y + half_rect_y


# changes scale and position of the cooldown radial
func set_scale_and_center_radial(_sprite_anchor, cooldown_radial):
	# set scale of radial, textures are too large by default
	cooldown_radial.rect_scale = base_cooldown_texture_scale


###############################################################################


func _on_GameTimer_Seconds_timeout():
	if is_time_passing:
		update_time()


func _on_WeaponSegmentTimer_timeout():
	weapon_cooldown.value += 1


func _on_Ability1SegmentTimer_timeout():
	ability1_cooldown.value += 1


func _on_Ability2SegmentTimer_timeout():
	ability2_cooldown.value += 1


###############################################################################


# enum_id is passed from
# player.gd 'ability_enum_id = weapon_ability_node.selected_weapon_style'
func update_cooldown(ability_type, ability_enum_id, new_value, new_max):
	if ability_type == BaseAbility.AbilityType.WEAPON:
		ui_modify_cooldown(weapon_cooldown, weapon_cooldown_segment_timer, new_value, new_max)
		if ability_enum_id != current_weapon_cooldown_ui_graphic:
			current_weapon_cooldown_ui_graphic = ability_enum_id
			update_ui_weapon_cooldown_graphic(ability_enum_id)
	elif ability_type == BaseAbility.AbilityType.ACTIVE:
		# blink
		if ability_enum_id == 0:
			ui_modify_cooldown(ability1_cooldown, ability1_cooldown_segment_timer, new_value, new_max)
		# time slow
		elif ability_enum_id == 1:
			ui_modify_cooldown(ability2_cooldown, ability2_cooldown_segment_timer, new_value, new_max)
		elif ability_enum_id == 2:
			ui_modify_cooldown(ability3_cooldown, ability3_cooldown_segment_timer, new_value, new_max)


func update_ui_weapon_cooldown_graphic(weapon_style_id):
	# get correct sprite paths
	var sprite_path_prog
	var sprite_path_under
	# get weapon type from passed style id
	var weapon_type = weapon.STYLE_DATA[weapon_style_id]
	# get file path for progress texture
	sprite_path_prog = weapon_type[weapon.DataType.WEAPON_ICON_SPRITE]
	# get file path without extension
	# append greyscale texture modification and extension
	sprite_path_under = sprite_path_prog.get_basename()+"_greyscale.png"
	
	# if textures are found, load correct texture
	if sprite_path_under != null:
		weapon_cooldown.texture_under = load(sprite_path_under)
	if sprite_path_prog != null:
		weapon_cooldown.texture_progress = load(sprite_path_prog)


func update_time():
	current_game_time_second -= 1
	if current_game_time_second < 0:
		current_game_time_second = 59
		current_game_time_minute -= 1
	
	# append 0 to single digit seconds
	var seconds_string = str(current_game_time_second)\
	 if current_game_time_second >= 10\
	 else "0"+str(current_game_time_second)
	
	game_time_label.text =\
	 str(current_game_time_minute) + ":" + str(seconds_string)



###############################################################################


func reset_timer(timer_to_set, new_wait_time):
	timer_to_set.stop()
	timer_to_set.wait_time = new_wait_time
	timer_to_set.start()


func ui_modify_cooldown(cooldown_node, cooldown_segment_timer, new_value, new_max):
	# set value of radial progress node on ui
	cooldown_node.value = new_value
	if new_max != null:
		cooldown_node.max_value = 32
		var segment_of_max = new_max/32
		reset_timer(cooldown_segment_timer, segment_of_max)
