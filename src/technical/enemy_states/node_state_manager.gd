
# the StateManager should be coupled to an Enemy node
# it handles the AI behaviour of the enemy
# how the enemy reacts to a player
# when they attack
# how they move
# etc

class_name StateManager, "res://art/shrek_pup_eye_sprite.png"
extends Node2D

# TODO conflict with class_state check_state signal, fix one or the other
signal check_state

# list of potential states for the enemy
enum State{
	IDLE,
	ROAMING,
	SEARCHING,
	HUNTING,
	ATTACK,
	HURT,
	DYING,
	SCANNING,
}

# what is the int id for the current active state
var current_state
# if no other state can be found, ignore condition and set this state
var default_state
# is the state manager allowed to check for state processing
var can_check_state_process = true
# is the state manager allowed to change states?
var can_change_active_state = true
# a list of states that were interrupted by an action state
var state_register = []
# dict containing references to state nodes
var state_call_dict = {}
# dict containing order in which to check states
var state_priority_dict = {}

# individual nodes for state handling
# state logic is partitioned amongst these node scripts
# do not change these variable names
# unless you are also changing the state call list logic
onready var state_node_idle = $State_Idle
onready var state_node_roaming = $State_Roaming
onready var state_node_searching = $State_Searching
onready var state_node_hunting = $State_Hunting
onready var state_node_attack = $State_Attack
onready var state_node_hurt = $State_Hurt
onready var state_node_dying = $State_Dying
onready var state_node_scanning = $State_Scanning


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_state_lists()
#	set_new_state(State.IDLE)
#	emit_signal("check_behaviour")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state == null:
		emit_signal("check_state")
	else:
		call_active_state_node_action()


###############################################################################


# changes state
# if state is an action state stores the old state to state register
func set_new_state(new_state):
	var check_action_state = get(state_call_dict[new_state])
	if check_action_state.is_action_state:
		state_register.append(current_state)
	current_state = new_state


# sets two dictionaries
# state call dict is for passing a state and getting back in return
# a string reference to the relevant state node (to use with get() func)
# state priority dict is for checking the order in which states should be
# checked for activation
# by default this is action/animating states like dying, hurt, attack
# at first, and less important states after (hunting, searching, roaming)
# but it is entirely customisable using the state_priority property
func set_state_lists():
	set_state_call_list()
	set_state_priority_list()
	state_priority_dict = sort_dictionary_by_int_value(state_priority_dict)


# create a dict of call references to compare current state to
# and get a state_variable
func set_state_call_list():
	var state_id
	var state_name
	# create a list of function call references
	for state_item in State:
		state_name = str(state_item)
		state_id = State[state_item]
		if GlobalDebug.enemy_state_logs: print(state_name, " is state #", state_id)
		
		var state_node_reference = "state_node_"+state_name.to_lower()
		# sets dict
		 # key as id# of the state enum
		 # value as references to state nodes using 
		# call the dict with current_state (when set to state.STATENAME)
		# to get the relevant state node
		state_call_dict[state_id] = state_node_reference


func set_state_priority_list():
#	var state_priority_dict = {}
	for state_to_check in state_call_dict:
		var state_node_call = get(state_call_dict[state_to_check])
		var current_state_priority = state_node_call.state_priority
		state_priority_dict[state_to_check] = current_state_priority
# print detail

###############################################################################


# call with State.STATENAME to get true/false on whether state can activate
func call_state_condition_check(state_identifier):
	# check the condition and return the same return
	var state_check =\
	get(state_call_dict[state_identifier]).check_state_condition()
	return state_check


# call this if a state can activate
# gets the state_action() function from the current state's node
func call_active_state_node_action():
	if current_state != null:
		get(state_call_dict[current_state]).state_action()


###############################################################################


# if need to check for a state change, check here
func _on_check_state():
	check_if_can_change_state()


func _on_clear_state():
	current_state = null


###############################################################################

func check_if_can_change_state():
	var new_state_found = null
	# check states in order of priority
	for state_to_check_condition in state_priority_dict:
		var current_state_condition = State.keys()[state_to_check_condition]
		if GlobalDebug.enemy_state_logs: print("checking State.", current_state_condition)
		if call_state_condition_check(state_to_check_condition):
			if GlobalDebug.enemy_state_logs: print("condition for State.", current_state_condition, " met!")
			new_state_found = state_to_check_condition
			break
		else:
			if GlobalDebug.enemy_state_logs: print("condition not met for State.", current_state_condition)
	# was a state found?
	if new_state_found != null:
		# debug string generation
		var old_state = " from State."+str(State.keys()[current_state]) if current_state != null else ""
		# debug string
		if GlobalDebug.enemy_state_logs: print("changing to State.", State.keys()[new_state_found], old_state)
		# change current state var to new state
		current_state = new_state_found
	else:
		if GlobalDebug.enemy_state_logs: print("no change in state")


# this function sorts a dictionary by value int order
# pass it a dict and it will return that dict organised by value
# descending from highest to lowest
# will purge non-int values so be wary of passing it dicts with non-int values
func sort_dictionary_by_int_value(given_dict):
	# variable initialising outside of loop scopes
	var new_dict = {}
	var highest_key
	var highest_value
	
	# non-int value exception/lockup handling
	# check how many non-int values there are
	var total_non_int_values_in_dict = 0
	for value in given_dict:
		if not value is int:
			total_non_int_values_in_dict += 1
			
	# loop until new dict size equals the old dict after non-int value purge
	while new_dict.size() != (given_dict.size()-total_non_int_values_in_dict):
		# clear highest key/value pair on new while loop
		highest_key = null
		highest_value = null
		# check each value
		for given_dict_key in given_dict:
			# if value is already in new dict, skip it
			if not given_dict_key in new_dict:
				var current_value = given_dict[given_dict_key]
				# if current checked value is the highest or first,
				# set it as the highest value
				if highest_value == null or current_value >= highest_value:
					highest_key = given_dict_key
					highest_value = current_value
		# append the current highest value
		new_dict[highest_key] = highest_value
	
#	print(new_dict)
#	for i in new_dict:
#		print(i, " ", new_dict[i])
	return new_dict


###############################################################################


## when looking for a state check individual state node requirements
## check logic and set state if conditions are met
#func recheck_state():
#
#	# CANNOT CHECK STATE
#	# if cannot check state, ignore state checking
#	# this will be set false if current state is an action state
#	if not can_check_state:
#		# return void/null
#		return
#
#	# IDLE STATE
#	# if not active, override everything
#	elif state_node_idle._state_check(current_target, target_last_known_location, current_state):
#		set_new_state(State.IDLE)
#
#	# ATTACK STATE
#	# do we have a target, are we able to fire?
#	# set state attack if not already
#	elif state_node_attack._state_check(current_target, target_last_known_location, current_state):
#		set_new_state(State.ATTACK)
#
#	# HUNT STATE
#	# if not do we have a target currently?
#	# set hunting state if not already
#	elif state_node_hunting._state_check(current_target, target_last_known_location, current_state):
#		set_new_state(State.HUNT)
#
#	# SEARCH STATE
#	# if we don't have a target
#	# but we do have a target last known location
#	# set searching state if not already
#	elif state_node_searching._state_check(current_target, target_last_known_location, current_state):
#		set_new_state(State.SEARCH)
#
#	# ROAMING STATE
#	# if no target, or last known location
#	# set roaming state if not already
#	elif state_node_roaming._state_check(current_target, target_last_known_location, current_state):
#		set_new_state(State.ROAMING)
#
#	# if no target
#	# look for a target
#	# this is the default logic on nothing being in the state register
#	# and no condition for another state being met
#	elif current_target == null:
#		set_new_state(State.SCANNING)
#
#	# Create state checking node?
#	# Move detection logic to detection handler node?
#	# Use signals to pass info to enemy to handle behaviour

# for getting state manager and enemy from base states
#	print(name, " owner is ", owner.name)
#	print(name, " owner of my owner ", owner.name, " is ", owner.owner.name
