
class_name StateHunting, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

signal approach_distance(is_at_maximum_approach)

const BASE_APPROACH_DISTANCE = 400

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


# if the state has a specific state emote, set the texture here
func set_state_emote_texture():
	state_emote_texture = GlobalReferences.state_emote_hunting
	emit_signal("new_state_texture", state_emote_texture)

################################################################################


# only should be called if state node has if_active set true
# divide approach distance by enemy aggression modifier
func get_approach_proximity():
	if is_active:
	# higher aggression = enemy continues to pursue
	# lower aggression = enemy stops further away
		return BASE_APPROACH_DISTANCE / enemy_parent_node.enemy_aggression_modifier


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
	
	# how close do we move to the target
	var maximum_approach_distance
	
	if is_active:

		
# if not set, set the detection manager
		if detection_manager == null:
			detection_manager = enemy_parent_node.detection_scan
	
		# process hunting target movement
		# get current_target of the detection manager
		var current_target = detection_manager.current_target
		# if we can see the target, update positon
		if check_target_is_visible(current_target):
			
			maximum_approach_distance = get_approach_proximity()
			
			# get enemy parent node's position
			var self_pos = enemy_parent_node.position
			# get current target of enemy parent's detection manager
			# then get the position of that target
			var target_pos = current_target.position
			# sets last known position - this is in case the target is lost suddenly
			detection_manager.target_last_known_location = target_pos
			# calls the enemy parent node's function for moving
#			if enemy_parent_node
			if self_pos.distance_to(target_pos) > maximum_approach_distance:
				enemy_parent_node.move_toward_given_position(self_pos, target_pos)
				emit_signal("approach_distance", false)
			else:
				enemy_parent_node.velocity = Vector2.ZERO
				emit_signal("approach_distance", true)
		# if we can't see target,
		else:
			# clear current target of detection manager
			detection_manager.current_target = null
			# need to check for new state
#			emit_signal("check_state")
		
		# process attack check
		# get the attack state node
		var attack_call = state_manager_node.state_node_attack
		# need to get if weapon can fire
		# if weapon fulfills condition
		if attack_call.check_state_condition():
			# ignore our state and check for new state
#			emit_signal("check_state")
		# currently check state signal is temp disabled due to lag problems
			state_manager_node.set_new_state(StateManager.State.ATTACK)


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
