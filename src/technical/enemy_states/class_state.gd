
class_name StateParent, "res://art/shrek_pup_eye_sprite.png"
extends Node2D

# action states interrupt other states (except action states)
# and remember their previous state via the state register
var is_action_state = false

# higher priortity states are checked first
# if equal checking is done alphabetically
var state_priority

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_state_priority()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# placeholer function to be derived by child classes
# if not derived will set all states to lowest priority
func set_state_priority():
	state_priority = 0

###############################################################################

# placeholder function to be derived by child classes
# returns false without any superseding child class function
func check_state_condition():
	if GlobalDebug.enemy_state_logs: print("checking condition for ", name)
	return false


# placeholder function to be derived by child classes
func state_action():
	if GlobalDebug.enemy_state_logs: print("taking action for ", name)
	pass

