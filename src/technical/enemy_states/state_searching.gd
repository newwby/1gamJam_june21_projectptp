
class_name StateSearching, "res://art/shrek_pup_eye_sprite.png"
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
	state_priority = 30
#
#
################################################################################
##
### placeholder function to be derived by child classes
### returns false without any superseding child class function
#func check_state_condition():
#	if is_active:
#		if enemy_parent_node.current_target == null:
#			return true
#	return false
##
##
### placeholder function to be derived by child classes
#func state_action():
#	var detector = enemy_parent_node.detection_scan
#	enemy_parent_node.current_target =\
#	 detector.get_closest_player_in_near_group()
