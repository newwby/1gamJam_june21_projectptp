
class_name StateScanning, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# set the state priority
func set_state_priority():
	state_priority = 0
#
################################################################################
#
## placeholder function to be derived by child classes
## returns false without any superseding child class function
#func check_state_condition():
#	return false
#
#
## placeholder function to be derived by child classes
#func state_action():
#	pass
