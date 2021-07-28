
class_name StateParent, "res://art/shrek_pup_eye_sprite.png"
extends Node2D

signal clear_state # DEBUGGER ISSUE, UNUSED
signal check_state # DEBUGGER ISSUE, UNUSED

var is_active = false

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
# the detection manager of the enemy parent node is also called frequently
var detection_manager# = owner.owner.detection_scan

# placeholder variable to be derived by child state classes with state emotes
var state_emote_node


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_state_priority()
	set_state_manager_and_enemy_self()
	set_state_signals()
	set_state_emote_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# placeholer function to be derived by child classes
# if not derived will set all states to lowest priority
func set_state_priority():
	state_priority = 0


# placeholer function to be derived by child classes
# if not derived will set the texture to null again
func set_state_emote_position():
	pass


# this set function is crucial to the operation of the state node system
func set_state_manager_and_enemy_self():
	# as mentioned in foreword, if these two variables can't be set
	# correctly, the state will disable itself to prevent exceptions
	
	var set_state_manager = false
	var set_enemy_parent = false
	
	# check if we can set state manager
	if owner != null and owner is StateManager:
		state_manager_node = owner
		if GlobalDebug.enemy_state_logs: print(self, " correctly set state manager as ", state_manager_node)
		set_state_manager = true
	else:
		if GlobalDebug.enemy_state_logs: print(self, " - error in setting state manager")
		is_active = false
		if GlobalDebug.enemy_state_logs: print(self, " node disabled")
	
	# check if we can set enemy parent
	if owner.owner != null and owner.owner is Enemy:
		enemy_parent_node = owner.owner
		# also get detection manager of enemy parent node
		yield(set_detection_manager(), "completed")
		if GlobalDebug.enemy_state_logs: print(self, " correctly set parent enemy node as ", enemy_parent_node)
		set_enemy_parent = true
	else:
		if GlobalDebug.enemy_state_logs: print(self, " - error in setting enemy self")
		is_active = false
		if GlobalDebug.enemy_state_logs: print(self, " node disabled")
	
	# only declare active if both were set
	if set_state_manager and set_enemy_parent:
		is_active = true
		if GlobalDebug.enemy_state_logs: print(self, " has been correctly set, state node ", name, " enabled")


# wait until parent's parent is ready before trying to set this variable
func set_detection_manager():
	yield(enemy_parent_node, "ready")
	detection_manager = enemy_parent_node.detection_scan
	


# placeholder function to be derived by child classes
func set_state_signals():
	# default signal connection
	# DEBUGGER ISSUE, UNUSED (both signals return values but neither are used)
	var _discard_value = self.connect("clear_state", state_manager_node, "_on_clear_state")
	_discard_value = self.connect("check_state", state_manager_node, "_on_check_state")

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


###############################################################################


# for removing debugger complaints
func voidfunc():
#	emit_signal("check_state")
	emit_signal("clear_state")
	emit_signal("new_state_texture")
