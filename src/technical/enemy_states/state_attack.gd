
class_name StateAttack, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

# TODO tie this to enemy parent reaction stat
var attack_delay_timer_wait_time = 0.1
var base_aim_timer_wait_timer = 0.25

onready var attack_delay = $AttackDelayTimer
onready var aim_pause = $AimingPauseTimer
onready var aim_randomisation = 0.75

# Called when the node enters the scene tree for the first time.
func _ready():
#	set_attack_delay_wait_time()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# set the state priority
func set_state_priority():
	state_priority = 50

# attack delay is set by enemy parent node perception
func set_attack_delay_wait_time():
	attack_delay.wait_time = attack_delay_timer_wait_time
	attack_delay.start()

#
################################################################################
#
## placeholder function to be derived by child classes
## returns false without any superseding child class function
func check_state_condition():
	var get_weapon_node = enemy_parent_node.weapon_node
	
	var get_target = detection_manager.current_target
	var firing_target = detection_manager.target_last_known_location
	
	if get_target != null and firing_target != null\
	and get_weapon_node.activation_timer.is_stopped():
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
			if get_target != null and firing_target != null:#\
#			and attack_delay.is_stopped():
				var aiming_vector = -(enemy_parent_node.position-firing_target)
				enemy_parent_node.current_mouse_target = aiming_vector
				enemy_parent_node.firing_target = aiming_vector
#				print("FIRE!")
				perform_attack(get_target.position, get_weapon_node)
				
			
			# start node behaviour again
			state_manager_node.set_new_state(StateManager.State.HUNTING)
#	get_weapon_node


func perform_attack(target_pos, weapon_node):
	if attack_delay.is_stopped():
		# start new delay timer
		attack_delay.start()
		# set line
		var enemy_target_line = enemy_parent_node.target_line
		enemy_target_line.look_at(target_pos)
		enemy_target_line.rotation_degrees -= 90
		enemy_target_line.visible = true
		
		# wait for aiming
		# TODO - this should probably be a set thing on init
		# calling random every time might be a bit over the top
		var wait_time_aim_randomisation =\
		 base_aim_timer_wait_timer +\
		 (GlobalFuncs.ReturnRandomRange(0, aim_randomisation))
		aim_pause.wait_time = wait_time_aim_randomisation
		aim_pause.start()
		yield(aim_pause, "timeout")
		
		# hide line
		enemy_target_line.visible = false
		# fire
		weapon_node.attempt_ability()
