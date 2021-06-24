
class_name Enemy
extends Actor

const ENEMY_TYPE_BASE_MOVEMENT_SPEED = 150

var is_active = true

# TODO replace weapon ability call with aiming_target var
# this is a fake variable to make weapon node work with enemy calss
var current_mouse_target
var firing_target
#
var show_sniper_line = true

var sprite_rescale_x = 0.75
var sprite_rescale_y = 0.75

var invert_squish = false
var horizontal_squish = Vector2(1.05, 0.95)
var vertical_squish = Vector2(0.95, 1.05)
var squish_randomness_cap = 0.05
var squish_duration  = 0.5

onready var enemy_sprite = $SpriteHolder/TestSprite
onready var target_line = $AbilityHolder/WeaponAbility/TargetLine
onready var squish_tween = $SpriteHolder/TestSprite/SquishingTween

onready var damage_immunity_timer = $SpriteHolder/TestSprite/DamageImmunityTimer

# stat PERCEPTION --
# stat PERCEPTION --
	# multiplies the initial detection radii
	# multiplies the additional size of additional detection radii
	# can be negative

# stat AGGRESSION --
	# how long does damage cause them to keep active (minimum)
		# 10x float for timer
	# how close do they move to target
		# float multiply close distance border
	# how long do they take to lose attention once off screen
		# 10x float for timer
	# how long do they pursue during second stage searching
		# 5x float for timer

var gamestat_reaction_speed = 20

# stat REACTION_SPEED --
	# how long additional time on top of weapon cooldown? (value/100)
	# initial cooldown multiplied by float of reaction speed
	# how many times per second the enemy can change state

onready var weapon_node = $AbilityHolder/WeaponAbility
onready var detection_scan = $DetectionHandler
onready var state_manager = $StateManager

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("enemies")
	set_enemy_stats()
	set_squish_randomness()
	Squish_Tween_Start()
#	set_initial_state(State.IDLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	_process_check_state()
#	_process_call_state_behaviour(delta)
	move_and_slide(velocity.normalized() * movement_speed)
#	detection_scan.player
	if state_manager.current_state != null:
		$DebugStateLabel.text = str(state_manager.current_state)
	if velocity != Vector2.ZERO:
		squish_tween.playback_speed = 2.0
	else:
		squish_tween.playback_speed = 0.5

###############################################################################


func set_squish_randomness():
	var random_squish =\
	 GlobalFuncs.ReturnRandomRange(\
	 -squish_randomness_cap, squish_randomness_cap)
	
	if random_squish < 0.03 and random_squish > 0:
		random_squish += 0.03
	elif random_squish < 0 and random_squish > -0.03:
		random_squish -= 0.03
	
	horizontal_squish = Vector2(\
	sprite_rescale_x - random_squish, sprite_rescale_y + random_squish)
	vertical_squish = Vector2(\
	sprite_rescale_x + random_squish, sprite_rescale_y - random_squish)
	squish_duration += random_squish


func set_enemy_stats():
	movement_speed = ENEMY_TYPE_BASE_MOVEMENT_SPEED


func set_enemy_weapon():
	var base_weapon


###############################################################################


func move_toward_given_position(self_position, target_position):
#	var velocity = Vector2.ZERO
	velocity = -(self_position - target_position)

###############################################################################

###############################################################################

###############################################################################

##DEFUNCT
## this function is for returning a state stored in the state register
## if we check state for something to do and state register is not
## empty then we pull the last state from the state register
#func check_state_register():
#	pass
#
#	# defunct/old logic for state_register
#	# TODO modify this to account for offscreen/idle check << ???
#	# if enemy is doing nothing and isn't already idle, set to idle
##	if not is_active\
##	 and current_state != State.IDLE\
##	 and state_register.size() == 0:
##		set_new_state(State.IDLE)



## defunct
#	# this is a call function for state behaviour
#func _process_call_state_behaviour(_dt):
#	# check state and move to that function
#	match current_state:
#
#		# enemy isn't active
#		State.IDLE:
#			state_node_idle._state_action()
#
#		# enemy is ambling around aimlessly
#		State.ROAMING:
#			state_node_roaming._state_action()
#
#		# enemy is moving toward last position they saw foe
#		State.SEARCH:
#			state_node_searching._state_action()
#
#		# enemy is actively chasing a player/can see a player
#		State.HUNT:
#			# need to add logic to check if can still see player
#
#			state_node_hunting._state_action(self, current_target)
#
#		# enemy is in range of a target and is initiating an attack
#		State.ATTACK:
#			state_node_attack._state_action()
#
#		# enemy has been injured and is playing hurt animation/logic
#		State.HURT:
#			state_node_hurt._state_action()
#
#		# enemy has been injured so much they are dying
#		State.DYING:
#			state_node_dying._state_action()
#
#		# enemy has been injured so much they are dying
#		State.SCANNING:
#			state_node_scanning.scan_for_player(\
#			get_tree().get_nodes_in_group(detection_scan.near_range_group))

## defunct
## check whether we can change state
#func _process_check_state():
#	# if state register not empty we get state from there
##	if state_register.size() > 0:
##		check_state_register()
#	# if not start checking state conditions
##	else:
#	recheck_state()


func _on_DetectionHandler_body_changed_detection_radius(body, is_entering_radius, range_group):
#	print(body, is_entering_radius, range_group)
	if body is Player\
	 and range_group == GlobalVariables.RangeGroup.NEAR:
		if is_entering_radius:
#			state_manager
			state_manager.set_new_state(StateManager.State.HUNTING)
			detection_scan.current_target = body
		if not is_entering_radius:
			state_manager.set_new_state(StateManager.State.SEARCHING)
#			state_manager.state_node_searching.start_timer()
#			.search_state_first_phase.start()
			detection_scan.current_target = null


func _on_OffscreenNotifier_screen_exited():
# implemented ham-fisted fix of the laggy initial state behaviour implementation
# implemented offscreen force of idle state
	state_manager.set_new_state(StateManager.State.IDLE)
	velocity = Vector2.ZERO
#	current_state = State.IDLE

func Squish_Tween_Start():
	var start_scale = horizontal_squish if invert_squish else vertical_squish
	var end_scale = vertical_squish if invert_squish else horizontal_squish
	squish_tween.interpolate_property(enemy_sprite, "scale",\
	 start_scale, end_scale, squish_duration,\
	 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	squish_tween.start()


func _on_SquishingTween_tween_all_completed():
	invert_squish = !invert_squish
	Squish_Tween_Start()


func _on_Enemy_damaged():
	if damage_immunity_timer.is_stopped():
		damage_immunity_timer.start_immunity()
