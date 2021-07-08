
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


## placeholder function to be derived by child classes
## returns false without any superseding child class function
func check_state_condition():
	if is_active:
		if enemy_parent_node.detection_scan.current_target == null:
			return true
	return false


# scanning state looks for a player that is within a range group of the enemy
# starting with the smallest range group (melee) and moving up
# does not scan the distant range group,
# targets beyond far are considered unseen
func state_action():
	# get the parent enemy node's detection manag
#	DetectionManager.get_closest_player_in_near_group()
	var detector = enemy_parent_node.detection_scan
	
	enemy_parent_node.detection_scan.current_target =\
	 detector.get_closest_player_in_near_group()
	emit_signal("check_state")
