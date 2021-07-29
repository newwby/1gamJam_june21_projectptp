
class_name Player
extends Actor

#var outline_material = load("res://src/effect/shadermaterial_glitch.tres").duplicate()

const VELOCITY_MULTIPLIER_IF_FIRING: float = 0.75
# this is the movement rate per tick of the player at instantiation
var BASE_PLAYER_MOVEMENT_SPEED = 300

var last_facing_not_firing: Vector2 = Vector2.ZERO

# player sprite is automatically resized according to this value
var sprite_intended_size = 100

var player_life = 10

# determine whether the player has immunity to damage from foes or not
# note: damage is damage to health from foes
# it does not include self-damage (a separate stat)
# it does not include any other timer related damage
# i.e. decrement over time, or ability usage
var is_damageable_by_foes = true

# determine whether the player is firing
var is_firing = false

# how fast does the orbital rotation node rotate
var orbiting_rotation_rate = 5

# where is the player aiming
var current_mouse_position: Vector2 = Vector2.ZERO
# direction the palyer is currently aiming
var current_mouse_target: Vector2 = Vector2.ZERO
# direction was the player aiming when they first started holding attack
var firing_target: Vector2 = Vector2.ZERO

# if sniper weapon we show this line between fire input and projectile spawn
var show_sniper_line: bool = false

# different settings for animation tween playback speed
var moving_anim_tween_playback_rate = 2.0
var static_anim_tween_playback_rate = 0.5

var glitch_effect_amplitude = 1.5
var glitch_effect_speed = 25

var ability_cooldown_blink_dash = 2.0
var ability_cooldown_time_slow = 12.0
var ability_cooldown_poo_bomb = 6.0

onready var player_sprite = $SpriteHolder/StaticSprite
onready var sprite_animation_tween = $SpriteHolder/StaticSprite/RockingTween

onready var weapon_ability_node = $AbilityHolder/WeaponAbility
onready var active_ability_node_1 = $AbilityHolder/ActiveAbility1 #q
onready var active_ability_node_2 = $AbilityHolder/ActiveAbility2 #e
onready var active_ability_node_3 = $AbilityHolder/ActiveAbility3 #r

onready var target_sprite_rotator = $TargetingSpriteHolder
onready var target_line_sniper = $TargetingSpriteHolder/TargetingSprite/SniperTargetingLine
onready var orbit_handler_node = $OrbitalProjectileHolder

onready var left_eye_sprite = $SpriteHolder/StaticSprite/EyeSprite_Left
onready var right_eye_sprite = $SpriteHolder/StaticSprite/EyeSprite_Right

onready var player_HUD = $UICanvasLayer/PlayerHUD

onready var damage_immunity_timer = $SpriteHolder/StaticSprite/DamageImmunityTimer

onready var lifeheart_1_hp012 = $UICanvasLayer/PlayerHUD/MarginContainer/TopHUDBar/TopRightHUD/HBox2/LifeBackground/HeartIcon1
onready var lifeheart_2_hp234 = $UICanvasLayer/PlayerHUD/MarginContainer/TopHUDBar/TopRightHUD/HBox2/LifeBackground/HeartIcon2
onready var lifeheart_3_hp456 = $UICanvasLayer/PlayerHUD/MarginContainer/TopHUDBar/TopRightHUD/HBox2/LifeBackground/HeartIcon3
onready var lifeheart_4_hp678 = $UICanvasLayer/PlayerHUD/MarginContainer/TopHUDBar/TopRightHUD/HBox2/LifeBackground/HeartIcon4
onready var lifeheart_5_hp8910 = $UICanvasLayer/PlayerHUD/MarginContainer/TopHUDBar/TopRightHUD/HBox2/LifeBackground/HeartIcon5

onready var player_shot_array_audio = $AudioEffectsHolder/WeaponFireEffects
onready var player_damaged_array_audio = $AudioEffectsHolder/DamagedEffects
onready var player_blink_ability_array_audio = $AudioEffectsHolder/AbilityBlinkEffects
onready var player_time_slow_ability_array_audio = $AudioEffectsHolder/AbilityTimeSlowEffects

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# adjust the player sprite according to (var sprite_intended_size)
	set_sprite_scale()
	set_ability_nodes()
	update_life_hearts()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		# check for player key input
		get_attack_input()
		get_ability_input()
		# handle per tick functions
		process_orbit_handler_rotate(delta)
		process_rotate_targeting_sprite(delta)
		process_rotate_sprite_eyes(delta)
		process_tween_speed(delta)

# for orbital and radar projectiles
func process_orbit_handler_rotate(_dt):
	# reversed rotation to fix projectiles spawning and vanishing
	# so they do so in the 'correct' order
	orbit_handler_node.rotation_degrees -= orbiting_rotation_rate


# target sprites point (arrow and sniper target line) point toward mouse pos
func process_rotate_targeting_sprite(_dt):
	target_line_sniper.visible = show_sniper_line
	target_sprite_rotator.visible = show_rotate_target_sprites
	# make sure these are allowed to rotate
	if can_rotate_target_sprites:
		# turn targeting sprite to look toward mouse cursor
		target_sprite_rotator.look_at(get_global_mouse_position())
		# godot engine problem brute force fix
		target_sprite_rotator.rotation_degrees += 90


# eyes turn to face the mouse cursor
func process_rotate_sprite_eyes(_dt):
	# make sprite eyes look at mouse cursor
	for eye in [left_eye_sprite, right_eye_sprite]:
		eye.look_at(get_global_mouse_position())


# player class override for handling movement, with key input
func process_handle_movement(_dt):
	if is_active:
		# move slower if firing
		var actual_movement_speed =\
		 movement_speed * VELOCITY_MULTIPLIER_IF_FIRING\
		if is_firing else movement_speed
		
		velocity = Vector2(0,0)
		velocity = get_movement_input() * actual_movement_speed
		var _collided_with = move_and_slide(velocity)


# control the speed of the animation based on whether the player is moving
func process_tween_speed(_dt):
	# if player is currently moving
	if is_moving and \
	 sprite_animation_tween.playback_speed != moving_anim_tween_playback_rate:
		# rock much faster, create illusion of walking
		sprite_animation_tween.playback_speed = moving_anim_tween_playback_rate
	# if player is not currently moving
	elif not is_moving and \
	 sprite_animation_tween.playback_speed != static_anim_tween_playback_rate:
		# rock much slower, create illusion of idle/stationary anim
		sprite_animation_tween.playback_speed = static_anim_tween_playback_rate


###############################################################################


# track any mouse movement as new co-ordinates for mouse position
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		current_mouse_position = event.position

###############################################################################


# player has a different base speed to default actor class
func set_player_base_speed():
	movement_speed = BASE_PLAYER_MOVEMENT_SPEED


# player sprite is scaled according to its own dimensions and the
# intended sprite size, adjusting scale by proportions
func set_sprite_scale():
	var get_sprite_dimensions = player_sprite.get_rect().size
		# calculate if the dimensions of the sprite are the same length or not
		
	var shorter_dimension
	if get_sprite_dimensions.x > get_sprite_dimensions.y:
		shorter_dimension = get_sprite_dimensions.y
	elif get_sprite_dimensions.y > get_sprite_dimensions.x:
		shorter_dimension = get_sprite_dimensions.x
	else:
		shorter_dimension = get_sprite_dimensions.x
	
	# apply the scale adjustment
	var sprite_scale_adj = sprite_intended_size/shorter_dimension
	player_sprite.scale = Vector2(sprite_scale_adj,sprite_scale_adj)


# sets the cooldown for ability nodes
# note: this should probably be moved into the ndoes themselves
# they could be setup with an enum id or exported var and auto-configure
func set_ability_nodes():
	active_ability_node_1.set_new_ability(GlobalVariables.AbilityTypes.BLINK)
	active_ability_node_1.activation_cooldown = ability_cooldown_blink_dash
	active_ability_node_2.set_new_ability(GlobalVariables.AbilityTypes.TIME_SLOW)
	active_ability_node_2.activation_cooldown = ability_cooldown_time_slow
	active_ability_node_3.set_new_ability(GlobalVariables.AbilityTypes.POO_BOMB)
	active_ability_node_3.activation_cooldown = ability_cooldown_poo_bomb


###############################################################################


# take movement input from the player
# calculate input direction accordingly
func get_movement_input():
	var input_direction = Vector2(0,0)
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	
	# save last direction moved for purposes of facing
	if input_direction != Vector2(0,0):
		last_facing = input_direction
		is_moving = true
	else:
		is_moving = false
	
	return input_direction.normalized()


# when fire button is pressed we store firing velocity
# when fire button is released we are allowed to store a new firing velocity
# hold button to fire
func get_attack_input():
	if is_active:
		if Input.is_action_pressed("fire_weapon"):
			
			if GlobalDebug.log_projectile_spawn_steps: ("get_attack_input_Input.is_action_pressed(fire_weapon):")
			current_mouse_target = -(self.position - get_global_mouse_position())
			if not is_firing:
				is_firing = true
				firing_target = current_mouse_target
			weapon_ability_node.attempt_ability()
		elif not Input.is_action_pressed("fire_weapon"):
			if is_firing:
				is_firing = false


# active ability calls
func get_ability_input():
	if is_active:
		if Input.is_action_pressed("power_item_1"):
			active_ability_node_1.attempt_ability()
		if Input.is_action_pressed("power_item_2"):
			active_ability_node_2.attempt_ability()
		if Input.is_action_pressed("alt_weapon"):
			active_ability_node_3.attempt_ability()


###############################################################################


func get_shot_sound_and_play():
	if GlobalDebug.PLAYER_SE_ENABLED:
		player_shot_array_audio.call_audio_array()


func get_damaged_sound_and_play():
	if GlobalDebug.PLAYER_SE_ENABLED:
		player_damaged_array_audio.call_audio_array()


func get_blink_sound_and_play():
	if GlobalDebug.PLAYER_SE_ENABLED:
		player_blink_ability_array_audio.call_audio_array()


func get_time_slow_sound_and_play():
	if GlobalDebug.PLAYER_SE_ENABLED:
		player_time_slow_ability_array_audio.call_audio_array()


###############################################################################


func _on_WeaponAbility_updated_cooldown(ability_node, ability_type, new_value, new_cooldown):
	if GlobalDebug.ability_cooldown_call_logs: print("signal from wep", ", ability_node=", ability_node, ", ability_type=", ability_type, ", new_value=", new_value, ", new_cooldown=", new_cooldown)
	handle_ability_cooldown_signal(ability_node, ability_type, new_value, new_cooldown)


# blink
func _on_ActiveAbility1_updated_cooldown(ability_node, ability_type, new_value, new_cooldown):
	if GlobalDebug.ability_cooldown_call_logs: print("signal from ab1", ", ability_node=", ability_node, ", ability_type=", ability_type, ", new_value=", new_value, ", new_cooldown=", new_cooldown)
	handle_ability_cooldown_signal(ability_node, ability_type, new_value, new_cooldown)


# time bubble
func _on_ActiveAbility2_updated_cooldown(ability_node, ability_type, new_value, new_cooldown):
	if GlobalDebug.ability_cooldown_call_logs: print("signal from ab2", ", ability_node=", ability_node, ", ability_type=", ability_type, ", new_value=", new_value, ", new_cooldown=", new_cooldown)
	if ability_node.is_active_time_bubble == false:
		handle_ability_cooldown_signal(ability_node, ability_type, new_value, new_cooldown)


func _on_ActiveAbility3_updated_cooldown(ability_node, ability_type, new_value, new_cooldown):
	if GlobalDebug.ability_cooldown_call_logs: print("signal from ab1", ", ability_node=", ability_node, ", ability_type=", ability_type, ", new_value=", new_value, ", new_cooldown=", new_cooldown)
	handle_ability_cooldown_signal(ability_node, ability_type, new_value, new_cooldown)


 # DEBUGGER ISSUE, 'damager' param UNUSED
func _on_Player_damaged(damage_taken, _damager):
	if damage_immunity_timer.is_stopped() and is_damageable_by_foes:
		damage_immunity_timer.start_immunity()
		var damage_taken_scaled = damage_taken/10
		if damage_taken_scaled < 1:
			damage_taken_scaled = 1
		player_life -= damage_taken_scaled
		get_damaged_sound_and_play()
		modify_glitch_effect(true)
		if player_life > 0:
			update_life_hearts()
		else:
			player_died()

func _on_GameEnvironment_game_started():
	player_HUD.is_time_passing = true
#	player_HUD._on_GameTimer_Seconds_timeout()


func _on_WeaponAbility_weapon_fired():
	get_shot_sound_and_play()


func _on_ActiveAbility1_activate_signal(ability_type):
	if ability_type == "blink":
		get_blink_sound_and_play()


func _on_ActiveAbility2_activate_signal(ability_type):
	if ability_type == "time_slow":
		get_time_slow_sound_and_play()


func _on_ActiveAbility3_activate_signal(ability_type):
	if ability_type == "poo_bomb":
		#play poo bomb sound
		# replace >> get_time_slow_sound_and_play()
		pass

###############################################################################


# player is a signal switchboard between ability nodes and HUD/UI
func handle_ability_cooldown_signal(ability_node, ability_type, new_value, new_cooldown):
	
	# need to pass to the UI
	# enum ID for weapon style or ability type
	# ability type so we know what to use enum id for
	# new value
	# new cooldown
#	func update_cooldown(ability_type, enum_id, new_value, new_max):
	
	var ability_enum_id
	if ability_type == BaseAbility.AbilityType.ACTIVE:
		ability_enum_id = ability_node.current_ability_loadout
		if GlobalDebug.ability_cooldown_call_logs: print("ability is enum id ", weapon_ability_node.selected_weapon_style)
	elif ability_type == BaseAbility.AbilityType.WEAPON:
		if weapon_ability_node != null:
			if GlobalDebug.ability_cooldown_call_logs: print("wep is enum id ", weapon_ability_node.selected_weapon_style)
			ability_enum_id = weapon_ability_node.selected_weapon_style
	
	# pass relevant info to the HUD
	if player_HUD != null:
		player_HUD.update_cooldown(\
		ability_type, ability_enum_id, new_value, new_cooldown)


###############################################################################


func modify_glitch_effect(turn_on):
	# get glitch parameters
	var new_glitch_effect_amplitude
	var new_glitch_effect_speed
	var can_set_glitch_effect = false
	if turn_on:
		new_glitch_effect_amplitude = glitch_effect_amplitude
		new_glitch_effect_speed = glitch_effect_speed
		can_set_glitch_effect = true
	elif not turn_on:
		new_glitch_effect_amplitude = 0
		new_glitch_effect_speed = 0
		can_set_glitch_effect = true
	# must have passed bool
	if can_set_glitch_effect:
		# set material shadeer's parameters to influence intensity of the effect
		player_sprite.material.set_shader_param("AMPLITUDE", new_glitch_effect_amplitude)
		player_sprite.material.set_shader_param("SPEED", new_glitch_effect_speed)
	#	player_sprite.material = outline_material


# update life heart gui
func update_life_hearts():
	#clear all
	lifeheart_1_hp012.value = 0
	lifeheart_2_hp234.value = 0
	lifeheart_3_hp456.value = 0
	lifeheart_4_hp678.value = 0
	lifeheart_5_hp8910.value = 0
	
	# min value is 0, max value is 2, can't underfill or overflow
	lifeheart_1_hp012.value = player_life# if player_life <= 2 else 2
	lifeheart_2_hp234.value = player_life-2# if player_life <= 4 else 2
	lifeheart_3_hp456.value = player_life-4# if player_life <= 6 else 2
	lifeheart_4_hp678.value = player_life-6# if player_life <= 8 else 2
	lifeheart_5_hp8910.value = player_life-8# if player_life <= 10 else 2


func player_died():
	self.queue_free()


func _on_DamageImmunityTimer_timeout():
	modify_glitch_effect(false)
