
class_name StateHunting, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

# defunct signals
#signal update_current_velocity
#signal is_current_target_visible

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

#func set_state_signals():
	# defunct signal connections
	# we should not be putting state behaviour in the enemy parent node
#	self.connect("update_current_velocity", enemy_parent_node, "on_update_velocity_with_current_target_position")
#	self.connect("is_current_target_visible", enemy_parent_node, "on_is_current_target_visible")
#	# set state signals should call parent class method
#	.set_state_signals()


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
	if is_active:
	#	emit_signal("update_current_velocity")
		track_and_move_toward_target()
		# need to update last known position
		# need to check if lost track of player
		
#		emit_signal("clear_state")
		# update current velocity to current target if they're not too close



# this function moves the enemy parent toward the current target
# without other logic will move on that heading forever
# if called repeatedly will chase the player perfectly
func track_and_move_toward_target():
	if is_active:
		
		# if not set, set the detection manager
		# TODO figure out why this is being called before state is set
		if detection_manager == null:
			detection_manager = enemy_parent_node.detection_scan
		
		# get current_target of the detection manager
		var current_target = detection_manager.current_target
		# if we can see the target, update positon
		if check_target_is_visible(current_target):
			# get enemy parent node's position
			var self_pos = enemy_parent_node.position
			# get current target of enemy parent's detection manager
			# then get the position of that target
			var target_pos = current_target.position
			# sets last known position - this is in case the target is lost suddenly
			detection_manager.target_last_known_location = target_pos
			# calls the enemy parent node's function for moving
			enemy_parent_node.move_toward_given_position(self_pos, target_pos)
		# if we can't see target,
		else:
			# clear current target of detection manager
			detection_manager.current_target = null
			# need to check for new state
			emit_signal("check_state")


# check if we can still see the target
func check_target_is_visible(target):
	# get group of nodes in near range
	var near_group =\
	 detection_manager.call_range_group(GlobalVariables.RangeGroup.NEAR)
	# check if current target is in that group
	var can_see_target =\
	 detection_manager.is_actor_in_range_group(target, near_group)
	return can_see_target

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
