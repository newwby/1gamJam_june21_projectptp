
class_name StateParent, "res://art/shrek_pup_eye_sprite.png"
extends Node2D

signal clear_state
signal check_state

var is_active = true

# action states interrupt other states (except action states)
# and remember their previous state via the state register
var is_action_state = false

# higher priortity states are checked first
# if equal checking is done alphabetically
var state_priority

# these two variables are inherit to the functioning of the state system
# they are initialised by code to prevent exceptions
# if the code does not successfully initialise each of these,
# they state will not function and will set 'is_active_ to false
# first
# the state manager is a coupled parent node that controls all state nodes
# without editing logic, state nodes should not be used without a manager
var state_manager_node# = owner
# second
# the state manager is child to an enemy node
# states are for controlling enemy nodes and without editing base logic,
# (as mentioned above), you should not use a state or state manager
var enemy_parent_node# = owner.owner


# Called when the node enters the scene tree for the first time.
func _ready():
	set_state_priority()
	set_state_manager_and_enemy_self()
	set_state_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# placeholer function to be derived by child classes
# if not derived will set all states to lowest priority
func set_state_priority():
	state_priority = 0


# this set function is crucial to the operation of the state node system
func set_state_manager_and_enemy_self():
	# as mentioned in foreword, if these two variables can't be set
	# correctly, the state will disable itself to prevent exceptions
	
	# check if we can set state manager
	if owner != null and owner is StateManager:
		state_manager_node = owner
		if GlobalDebug.enemy_state_logs: print(self, " correctly set state manager as ", state_manager_node)
	else:
		if GlobalDebug.enemy_state_logs: print(self, " - error in setting state manager")
		is_active = false
		if GlobalDebug.enemy_state_logs: print(self, " node disabled")
	
	# check if we can set enemy parent
	if owner.owner != null and owner.owner is Enemy:
		enemy_parent_node = owner.owner
		if GlobalDebug.enemy_state_logs: print(self, " correctly set parent enemy node as ", enemy_parent_node)
	else:
		if GlobalDebug.enemy_state_logs: print(self, " - error in setting enemy self")
		is_active = false
		if GlobalDebug.enemy_state_logs: print(self, " node disabled")


# placeholder function to be derived by child classes
func set_state_signals():
	# default signal connection
	self.connect("clear_state", state_manager_node, "on_clear_state")
	self.connect("check_state", state_manager_node, "_on_check_behaviour")

###############################################################################

# placeholder function to be derived by child classes
# returns false without any superseding child class function
func check_state_condition():
	if is_active:
		if GlobalDebug.enemy_state_logs: print("checking condition for node ", name)
		return false
	else:
		if GlobalDebug.enemy_state_logs: print(name, " node cannot have condition checked - is_active is set false")
		return false


# placeholder function to be derived by child classes
func state_action():
	if is_active:
		if GlobalDebug.enemy_state_logs: print("taking action for node ", name)
	else:
		if GlobalDebug.enemy_state_logs: print("failed attempt at action for node ", name, " - is_active is set false")

