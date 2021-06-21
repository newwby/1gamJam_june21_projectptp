
class_name StateHunting, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

signal update_current_velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# set the state priority
func set_state_priority():
	state_priority = 40

func set_state_signals():
	self.connect("update_current_velocity", enemy_parent_node, "on_update_velocity_with_current_target_position")
	.set_state_signals()
#	enemy_parent_node.connect("update_current_velocity", self, on_update_velocity_with_current_target_position)


#
################################################################################
#
## placeholder function to be derived by child classes
## returns false without any superseding child class function
func check_state_condition():
	# make sure state is active
	if is_active:
		if enemy_parent_node.detection_scan.current_target != null:
			return true
	
	# if fail a check above, return condition as false
	return false
#
#
## placeholder function to be derived by child classes
func state_action():
	emit_signal("update_current_velocity")
	# need to update last known position
	# need to check if lost track of player
	emit_signal("clear_state")
	# update current velocity to current target if they're not too close


################################################################################


# defunct
#func find_closest_player_in_near_group():
#	# find detection manager of enemy parent
#	var detection_manager = enemy_parent_node.detection_scan
#	var near_group
#
#	# make sure detection manager was found
#	if detection_manager != null:
#		# get group in the near range of the enemy
#		near_group =\
#		 get_tree().get_nodes_in_group(detection_manager.near_range_group)
#
#	# make sure we got the group (it isn't empty)
#	if near_group != null:
#		# get the closest player
#		var closest_player =\
#		 detection_manager.get_nearest_player_in_range_group(near_group)
#		# make sure closest_player is in fact a player
#		if closest_player is Player:
#			return Player
