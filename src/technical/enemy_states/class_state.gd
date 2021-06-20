
class_name State, "res://art/shrek_pup_eye_sprite.png"
extends Node2D

signal update_velocity

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


# boilerplate function to be derived by individual child states
func _state_check(current_target, target_last_known_pos, current_state):
	# returns false if no overriding logic, so can't be enabled
	if GlobalDebug.enemy_state_logs: print("checking state ", name)
	return false


# boilerplate function to be derived by individual child states
func _state_action(enemy_node = null, current_target = null):
	pass


###############################################################################


func get_nearby_location(distance_from_self):
	# return position
	return Vector2.ZERO


func move_toward_given_position(self_position, target_position):
	var velocity = Vector2.ZERO
	velocity = -(self_position - target_position)
	emit_signal("update_velocity", velocity)


###############################################################################


# scan to see if there's anything in near range or closer
func check_if_player_at_near_range():
	pass


# scan to see if there's anything in far range or closer
func check_if_player_at_far_range():
	pass


func check_if_target_in_range_group(check_target, range_group):
	# change this to build array of targets in range_group (range_string) then check
#	if check_target in range_group:
	pass


# if nearby target last known location empty the last known location
func check_distance_to_target_last_known_location():
	pass


###############################################################################


# identify all players in a range detection group
func get_players_in_range_group(range_group_to_scan):
	var potential_targets = []
	# scan all valid targets
	for i in range_group_to_scan:
		if i is Player:
			potential_targets.append(i)
	# return the group of nodes if not empty
	if potential_targets.size() > 0:
		return potential_targets

# get the nearest in a generated group of nodes
func get_closest_in_group_of_targets(potential_targets):
	# clear these variables
	var closest_target = null
	var closest_target_distance = null
	
	# check who is the closest valid target
	# is there are least one potential target?
	if potential_targets != null:
		if potential_targets.size() > 0:
			# loop through
			for i in potential_targets:
				# how far away are they
				var get_distance = position.distance_to(i.position)
				# if haven't set ctd, set it
				if closest_target_distance == null:
					closest_target_distance = get_distance
					closest_target = i
				# if ctd has been set, is the new target closer?
				# if they are, they are now the closest target
				elif get_distance < closest_target_distance:
					closest_target_distance = get_distance
					closest_target = i
	
	# return the nearest target
	if closest_target != null:
		return closest_target


func get_nearest_player_in_range_group(range_group_to_scan):
	# set null variables
	var target_list
	var closest_target
	# target list is a list of valid players
	target_list = get_players_in_range_group(range_group_to_scan)
	# closest target is the nearest in the list
	closest_target = get_closest_in_group_of_targets(target_list)
	# return the closest target
	return closest_target


###############################################################################


# enemy has moved offscreen during non-idle state
# begin timer to force switch to idle state
func offscreen_start_attention_loss_timer():
	pass


# attention loss timer has expired
func offscreen_has_lost_attention():
	pass


# if damaged by target enemy didn't see, engage hunting state
# maintain hunting state whilst aggression timer is engaged
func damaged_by_unseen_target():
	pass


###############################################################################

