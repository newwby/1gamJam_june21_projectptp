
class_name Enemy
extends Actor

enum State{
	IDLE,
	WANDER,
	SEARCH,
	HUNT,
	ATTACK,
	HURT,
	DYING
}

const ENEMY_TYPE_BASE_MOVEMENT_SPEED = 150

# if in these states ignore rechecking of states
var action_state_override = [\
	State.ATTACK,\
	State.HURT,\
	State.DYING,]

var is_active = true
var can_check_state = true

# the current actor the enemy is hunting
var current_target
# last known location of the target if lost sight of them
var target_last_known_location

# the current state the enemy is in
var current_state
# states that the enemy was previously in that still need to be resolved
var state_register = []

var wander_to_position
var wandering_distance_minimum
var wandering_distance_maximum
var wandering_timer_minimum
var wandering_timer_maximum
var distance_to_wandering_position_to_complete

onready var wandering_timer = $StateComponentHolder/WanderingRepeatTImer

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
	set_initial_state(State.IDLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_check_state:
		_process_check_state()
	_process_call_state_behaviour(delta)
	move_and_slide(velocity.normalized() * movement_speed)

###############################################################################


	# this is a call function for state behaviour
func _process_call_state_behaviour(_dt):
	# check state and move to that function
	match current_state:
	
		# enemy is ambling around aimlessly
		State.WANDER:
			# state_idle()
			pass
	
		# enemy is moving toward last position they saw foe
		State.SEARCH:
			state_searching_move_toward_target_last_known_position()
	
		# enemy is actively chasing a player/can see a player
		State.HUNT:
			state_hunting_move_and_track_target()
	
		# enemy is in range of a target and is initiating an attack
		State.ATTACK:
			state_attack_activate_weapon()
	
		# enemy has been injured and is playing hurt animation/logic
		State.HURT:
			state_hurt_enemy_is_damaged()
	
		# enemy has been injured so much they are dying
		State.DYING:
			state_dying_enemy_begins_to_die()


# check whether we can change state
func _process_check_state():
	# if enemy is doing nothing and isn't already idle, set to idle
	# TODO modify this to account for offscreen/idle check
	if not is_active\
	 and current_state != State.IDLE\
	 and state_register.size() == 0:
		set_new_state(State.IDLE)
	
	recheck_state()


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
	print("new state is ", State.keys()[new_state])


###############################################################################


# when not already in an active
func recheck_state():
	
	# IF ACTIVE STATE
	# OVERRIDE ALL STATES
	# if attacking, hurt or dying, ignore state checking
	# if cannot check state, ignore state checking
	if current_state in action_state_override\
	 or not can_check_state:
		# return void/null
		return
	
	# IDLE STATE
	# if not active, override everything
	elif not is_active\
	 and current_state != State.IDLE:
		set_new_state(State.IDLE)
	
	# ATTACK STATE
	# do we have a target, are we able to fire?
	# set state attack if not already
	elif current_target != null and check_if_weapon_can_fire()\
	 and current_state != State.ATTACK:
		set_new_state(State.ATTACK)
	
	# HUNT STATE
	# if not do we have a target currently?
	# set hunting state if not already
	elif current_target != null\
	 and current_state != State.HUNT:
		set_new_state(State.HUNT)

	# SEARCH STATE
	# if we don't have a target
	# but we do have a target last known location
	# set searching state if not already
	elif current_target == null\
	 and target_last_known_location != null\
	 and current_state != State.SEARCH:
		set_new_state(State.SEARCH)
	
	# WANDERING STATE
	# if no target, or last known location
	# set wandering state if not already
	elif current_target == null\
	 and target_last_known_location == null\
	 and is_active\
	 and current_state != State.WANDER:
		set_new_state(State.WANDER)
	
	# if no target
	# look for a target
	elif current_target == null:
		look_for_targets()
	
	# Create state checking node?
	# Move detection logic to detection handler node?
	# Use signals to pass info to enemy to handle behaviour
	
	
	# If can't see nearby target, is there someone further away?
		# Check far group, if we find a target
			# Store target position and move toward target position
			# Every tick/process
				# Check if we can attack
				# Check if we see anyone
	
	# If hurt, change state and append state register
		# Check if dead
			# Stop all other processing
			# Process dead
		# If not dead
			# Process hurt
			# Check state

###############################################################################


# WANDERING STATE
# get random location nearby and move there
func state_wandering_move_to_random_nearby_location():
	# TODO move variablse out of this scope
	# TODO if within variable range
		# randomise within range then start wander pause timer
#	# if wander pause timer running no more wandering
#	var wander_to_position
#	var wandering_distance_minimum
#	var wandering_distance_maximum
#	var wandering_timer_minimum
#	var wandering_timer_maximum
#	var distance_to_wandering_position_to_complete
#
#	var wandering_timer = Timer.new()
	
	# if wandering position set, wander until close
	if wander_to_position != null:
		if check_if_near_wandering_position():
			wander_to_position = null
			start_and_randomise_wandering_timer()
	
	# check if no current wandering but can start
	elif wandering_timer.is_stopped() and\
	 wander_to_position == null:
		# set a new wandering position
		wander_to_position = get_nearby_location(\
		GlobalFuncs.ReturnRandomRange(\
		wandering_distance_minimum, wandering_distance_maximum))


# SEARCHING STATE
# move toward target's last known position
# check if we reached it, if so empty the last known location
func state_searching_move_toward_target_last_known_position():
	move_toward_given_position(target_last_known_location)
	check_distance_to_target_last_known_location()


# HUNTING STATE
# move toward target, keep looking at target, try to fire
func state_hunting_move_and_track_target():
	# If not firing - Do we have a target?
	# Move toward target
	# Every tick/process
		# Check if we can attack
		# Update our target position
	if current_target != null:
		move_toward_given_position(current_target.position)
		check_if_can_still_see_target(current_target)
		check_if_weapon_can_fire()
	else:
		recheck_state()


# ATTACK STATE
# get the target, create target line, delay according to reaction, fire, 
func state_attack_activate_weapon():
	var weapon_target = acquire_weapon_target()
				# Prep to fire at that target
					# Anticipate/pause
					# Create target line
					# Timer delay before firing
					# Fire shot/trigger weapon
					# Recover/pause
					# Set attack cooldown timer
					# GOTO CHECK STATE


# HURT STATE
# interrupts behaviour and starts damaged/aggression timer
func state_hurt_enemy_is_damaged():
	handle_enemy_taking_damage()


# DYING STATE
# stop everything else, end the enemy
func state_dying_enemy_begins_to_die():
	handle_enemy_dying()


###############################################################################


func check_if_weapon_can_fire():
	# if weapon not on cooldown (including reaction fire adjustment)
	# and enemy is within allowed range_groups of target
	if check_if_weapon_not_on_cooldown()\
	and check_if_weapon_is_in_range():
		return true
	else:
		return false


# get weapon cooldown timer, multiply with reaction speed
func check_if_weapon_not_on_cooldown():
	# Check weapon timer (multiply base attack by enemy reaction speed)
	# return true false
	pass


func check_if_weapon_is_in_range():
	# return true false
	pass
		# Check weapon range condition
			# Get weapon range minmum and maximum
			# Get range groups for minimum, maximum, and all inbetween
			# Build a combined range group
			# Don't duplicate (check if node in group)
			# If it isn't empty, we can attack!


# scan to see if there's anything in near range or closer
func check_if_foe_at_near_range():
	pass


# scan to see if there's anything in far range or closer
func check_if_foe_at_far_range():
	pass


# checks to see if target is at near range
func check_if_can_still_see_target(check_target):
	pass


func check_if_target_in_range_group(check_target, range_group):
	# change this to build array of targets in range_group (range_string) then check
#	if check_target in range_group:
	pass


# if nearby target last known location empty the last known location
func check_distance_to_target_last_known_location():
	pass


func check_if_near_wandering_position():
	if position.distance_to(wander_to_position) <\
	 distance_to_wandering_position_to_complete:
		return true
	else:
		return false


###############################################################################


# identify all players in a range detection group
func get_players_in_range_group(range_group_to_scan):
	var potential_targets = []
	# scan all valid targets
	for i in range_group_to_scan:
		if i is Player:
			potential_targets.append(i)
	# return the group of nodes if not empty
	if potential_targets.size() > 0:
		return potential_targets

# get the nearest in a generated group of nodes
func get_closest_in_group_of_targets(potential_targets):
	# clear these variables
	var closest_target = null
	var closest_target_distance = null
	
	# check who is the closest valid target
	# is there are least one potential target?
	if potential_targets != null:
		if potential_targets.size() > 0:
			# loop through
			for i in potential_targets:
				# how far away are they
				var get_distance = position.distance_to(i.position)
				# if haven't set ctd, set it
				if closest_target_distance == null:
					closest_target_distance = get_distance
					closest_target = i
				# if ctd has been set, is the new target closer?
				# if they are, they are now the closest target
				elif get_distance < closest_target_distance:
					closest_target_distance = get_distance
					closest_target = i
	
	# return the nearest target
	if closest_target != null:
		return closest_target


func get_nearest_player_in_range_group(range_group_to_scan):
	# set null variables
	var target_list
	var closest_target
	# target list is a list of valid players
	target_list = get_players_in_range_group(range_group_to_scan)
	# closest target is the nearest in the list
	closest_target = get_closest_in_group_of_targets(target_list)
	# return the closest target
	return closest_target


###############################################################################


###############################################################################


func acquire_weapon_target():
	pass
	# Figure out who is closest enemy


func move_toward_given_position(target_position):
	velocity = -(position - target_position)


# enemy has moved offscreen during non-idle state
# begin timer to force switch to idle state
func offscreen_start_attention_loss_timer():
	pass


# attention loss timer has expired
func offscreen_has_lost_attention():
	pass


# if damaged by target enemy didn't see, engage hunting state
# maintain hunting state whilst aggression timer is engaged
func damaged_by_unseen_target():
	pass


func start_and_randomise_wandering_timer():
#	wandering_timer.wait_time = random_value
	pass

func get_nearby_location(distance_from_self):
	# return position
	return Vector2.ZERO


	# we set current_target if fulfilling condition
func look_for_targets():
		check_if_foe_at_near_range()


# actual function for hurt state
func handle_enemy_taking_damage():
	pass


# actual function for dying state
func handle_enemy_dying():
	pass


###############################################################################

