
class_name Enemy
extends Actor

const ENEMY_TYPE_BASE_MOVEMENT_SPEED = 150

var is_active = true

# the current actor the enemy is hunting
var current_target
# last known location of the target if lost sight of them
var target_last_known_location

# the current state the enemy is in
var current_state
# states that the enemy was previously in that still need to be resolved
var state_register = []

# stat AGGRESSION --
	# how long does damage cause them to keep active (minimum)
		# 10x float for timer
	# how close do they move to target
		# float multiply close distance border
	# how long do they take to lose attention once off screen
		# 5x float for timer

# stat REACTION_SPEED --
	# how long additional time on top of weapon cooldown?
	# initial cooldown multiplied by float of reaction speed

onready var detection_scan = $DetectionRadiiHandler


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("enemies")
	set_enemy_stats()
#	set_initial_state(State.IDLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	_process_check_state()
#	_process_call_state_behaviour(delta)
	move_and_slide(velocity.normalized() * movement_speed)


###############################################################################




###############################################################################


func set_enemy_stats():
	movement_speed = ENEMY_TYPE_BASE_MOVEMENT_SPEED


# set the first state and clear the state register
func set_initial_state(starting_state):
	state_register = []
	current_state = starting_state


# change our state
func set_new_state(new_state):
	state_register.append(current_state)
	current_state = new_state
#	if GlobalDebug.enemy_state_logs: print("new state is ", State.keys()[new_state])



###############################################################################


###############################################################################





###############################################################################
#
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
