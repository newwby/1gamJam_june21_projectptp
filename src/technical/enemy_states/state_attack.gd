
class_name StateAttack, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

const BASE_ATTACK_DELAY = 0.1
const BASE_AIM_PAUSE = 0.25
const BASE_ATTACK_CHECK_FREQUENCY = 0.5

var attack_delay_timer_wait_time = 0.1
var aim_pause_timer_wait_time = 0.25
var attack_check_frequency_timer_wait_time = 0.1

var is_currently_firing = false

onready var attack_delay_timer = $AttackDelay
onready var aim_pause_timer = $AimingPause
onready var attack_check_frequency_timer = $AttackCheckFrequency
onready var aim_randomisation = 0.75

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################


# set the state priority
func set_state_priority():
	state_priority = 50


## set attack reaction times that are modified by reaction gamestat
## call if reaction gamestat is modified
# this function is currently unused/uncalled
func set_attack_perception_timers():
	# no current reaction gamestat implementation (on enemy_parent_node)
	attack_check_frequency_timer_wait_time = BASE_ATTACK_CHECK_FREQUENCY
	aim_pause_timer_wait_time = BASE_AIM_PAUSE
	attack_delay_timer_wait_time = BASE_ATTACK_DELAY
	# set timers to these adjusted values
	attack_check_frequency_timer.wait_time = attack_check_frequency_timer_wait_time
	aim_pause_timer.wait_time = aim_pause_timer_wait_time
	attack_delay_timer.wait_time = attack_delay_timer_wait_time


################################################################################


# weapon data of enemy parent node determines minimum and maximum fire range
# this function is the only function that should call the two functions below 
func is_attack_range_valid():
	# enemy parent node must be set first of all, else can't run this
	if is_active:
		# if not already set, set the detection manager
		if detection_manager == null:
			detection_manager = enemy_parent_node.detection_scan
		# check there is a current target, and it is a player, if not break
		if detection_manager.current_target is Player:
			# pass the functions the current target
			if get_attack_range_minimum(detection_manager.current_target) \
			and get_attack_range_maximum(detection_manager.current_target):
				return true
			else:
				return false


# in both the following functions 'get_range' grabs an enum id for
# GlobalVariables.RangeGroup, which can then be used with the enemy's 
# detection manager node's function 'call_range_group(range_id)' to
# return an array with the nodes in said range group
#
# for maximum, if player is in the group, return true
# check if NOT inside range groups smaller than the minimum range group
# currently this will override minimum range to fire if at approach distance
func get_attack_range_minimum(target_node):
	var get_range = enemy_parent_node.weapon_node.ai_weapon_minimum_range
	# set a bool on whether we're too close to the target to fire
	var too_close = false
	if GlobalDebug.attack_weapon_range_checking: print(enemy_parent_node, "/", enemy_parent_node.name, " checking minimum attack range")
	if GlobalDebug.attack_weapon_range_checking: print("checking versus ", target_node, "/", target_node.name)
	
	# return true immediately if at maximum approach
	# overrides other behaviour
	if enemy_parent_node.approach_flag:
		if GlobalDebug.attack_weapon_range_checking: print("maximum approach override/break")
		return true
	else:
		# check range groups lower than the minimum
		var loop_counter = get_range-1
		# will loop until first key, loop once more, then stop
		while loop_counter > 0:
	#		var lower_range_group_check = GlobalVariables.RangeGroup(loop_counter)
			if GlobalDebug.attack_weapon_range_checking: print("checking range group ", loop_counter, "/", GlobalVariables.RangeGroup.keys()[loop_counter])
			if target_node in detection_manager.call_range_group(loop_counter):
				too_close = true
				if GlobalDebug.attack_weapon_range_checking: print("target found in lower range group, failure")
			# before we loop again we decrement the count to prevent infiniloops
			loop_counter -= 1
		
		# if not too close, we're outside or at minimum range
		return !too_close


# this function checks if inside the given maximum range group
# as before, but for minimum we check the lower groups (use the get_range
# enum id and loop until 0, as they're set sequentially (ascending from melee).
# return false if in any lower group
func get_attack_range_maximum(target_node):
	var get_range = enemy_parent_node.weapon_node.ai_weapon_maximum_range
	
	# debug console logging handling
	if GlobalDebug.attack_weapon_range_checking: print(enemy_parent_node, "/", enemy_parent_node.name, " checking maximum attack range")
	if GlobalDebug.attack_weapon_range_checking: print("checking versus ", target_node, "/", target_node.name)
	if GlobalDebug.attack_weapon_range_checking: print("checking range group ", get_range, "/", GlobalVariables.RangeGroup.keys()[get_range])
	# check if in said range_group
	# if it is not inside the range group, it must be outside that range group
	# anything outside that range group exceeds the maximum range
	if target_node in detection_manager.call_range_group(get_range):
		if GlobalDebug.attack_weapon_range_checking: print("target found in range group!!!")
		return true
	else:
		if GlobalDebug.attack_weapon_range_checking: print("target NOT FOUND.")
		return false


################################################################################


## placeholder function to be derived by child classes
## returns false without any superseding child class function
func check_state_condition():
	var get_weapon_node = enemy_parent_node.weapon_node
	
	var get_target = detection_manager.current_target
	var firing_target = detection_manager.target_last_known_location
	
	if get_target != null and firing_target != null\
	and get_weapon_node.activation_timer.is_stopped()\
	and is_attack_range_valid():
		return true
	else:
		return false
#
#
## placeholder function to be derived by child classes
func state_action():
	if is_active:
		if enemy_parent_node != null:# and detection_manager != null:
			# stop the enemy node
			enemy_parent_node.velocity = Vector2.ZERO
			var get_weapon_node = enemy_parent_node.weapon_node
			var get_target = detection_manager.current_target
#			print("find target", detection_manager, get_target, detection_manager.current_target)
			var firing_target = detection_manager.target_last_known_location
			if get_target != null and firing_target != null and not is_currently_firing:#\
#			and attack_delay.is_stopped():
				var aiming_vector = -(enemy_parent_node.position-firing_target)
				enemy_parent_node.current_mouse_target = aiming_vector
				enemy_parent_node.firing_target = aiming_vector
#				print("FIRE!")
				perform_attack(get_target.position, get_weapon_node)
			else:
				return_to_hunting_state()


func perform_attack(target_pos, weapon_node):
	if attack_delay_timer.is_stopped() and enemy_parent_node.is_active:
		is_currently_firing = true
		# start new delay timer
		attack_delay_timer.start()
		# set line
		var enemy_target_line = enemy_parent_node.target_line
		enemy_target_line.look_at(target_pos)
		enemy_target_line.rotation_degrees -= 90
		enemy_target_line.visible = true
		
		var wait_time_aim_randomisation =\
		 aim_pause_timer_wait_time +\
		 (GlobalFuncs.ReturnRandomRange(0, aim_randomisation))
		aim_pause_timer.wait_time = wait_time_aim_randomisation
		aim_pause_timer.start()
		yield(aim_pause_timer, "timeout")
		
		# hide line
		enemy_target_line.visible = false
		# fire
		weapon_node.attempt_ability()
		enemy_parent_node.get_shot_sound_and_play()
		is_currently_firing = false


func return_to_hunting_state():
#	pass
#	# start node behaviour again
	if state_manager_node.current_state == StateManager.State.ATTACK:
		state_manager_node.set_new_state(StateManager.State.HUNTING)
		# behaviour hangup where hunting state isn't doing anything
		# TEMP THIS IS WHERE THE STATE BEHAVIOUR HANGUP IS
#		print("# TEMP THIS IS WHERE THE STATE BEHAVIOUR HANGUP IS")
#		emit_signal("check_state")
