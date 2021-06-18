extends Control

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

var is_time_passing = true

var chosen_difficulty = GameDifficulty.NORMAL

# NOTE: damage removes time, (skill use removes time?)

var current_game_time_minute = 0
var current_game_time_second = 0

onready var weapon_cooldown = $CooldownRadialHolder/WeaponCooldownRadial
onready var ability1_cooldown = $CooldownRadialHolder/Ability1CooldownRadial
onready var ability2_cooldown = $CooldownRadialHolder/Ability2CooldownRadial

onready var decor_strip = $CooldownRadialHolder/CooldownDecorStripe

onready var weapon_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Weapon/WeaponSpriteAnchor
onready var ability1_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Ability1/AbilitySprite1Anchor
onready var ability2_sprite = $MarginContainer/TopHUDBar/TopLeftHUD/HBox/HBox/Ability2/AbilitySprite2Anchor

onready var game_time_label = $ClockLabel
onready var game_timer = $GameTimer_Seconds

###############################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	set_game_time()
	set_game_timer()
	set_cooldown_texture_positions_and_dimensions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	scale_and_center_radial(weapon_sprite, weapon_cooldown)
	scale_and_center_radial(ability1_sprite, ability1_cooldown)
	scale_and_center_radial(ability2_sprite, ability2_cooldown)
	# account for scale adjustment when getting rect size
	var half_rect_y = (weapon_cooldown.rect_size.y * weapon_cooldown.rect_scale.y) / 8
	# set decor strip to be positioned with radial cooldown timers
	decor_strip.rect_position.y =\
	 weapon_cooldown.rect_position.y + half_rect_y


# changes scale and position of the cooldown radial
func scale_and_center_radial(sprite_anchor, cooldown_radial):
	# set scale of radial, textures are too large by default
	cooldown_radial.rect_scale = base_cooldown_texture_scale
	# adjust for set scale
	var half_texture_size =\
	 (sprite_anchor.texture.get_size() * sprite_anchor.scale) / 2.5
	# position setting currently disabled due to problems with the UI controls
#	cooldown_radial.rect_position = sprite_anchor.position+half_texture_size


###############################################################################

func update_cooldown(cooldown_to_update, value_to_pass):
	pass


func update_time():
	current_game_time_second -= 1
	if current_game_time_second < 0:
		current_game_time_second = 59
		current_game_time_minute -= 1
	
	game_time_label.text =\
	 str(current_game_time_minute) + ":" + str(current_game_time_second)


func _on_GameTimer_Seconds_timeout():
	if is_time_passing:
		update_time()

