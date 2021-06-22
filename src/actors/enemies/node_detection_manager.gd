
class_name DetectionManager, "res://art/projectile/kenney_particlePack_1.1/circle_03.png"
extends Node2D

signal body_changed_detection_radius(body, is_entering_radius, range_group)

#			state_manager_node.set_new_state(StateManager.State.ATTACK)
# the current actor the enemy is hunting
var current_target
# last known location of the target if lost sight of them
var target_last_known_location

var range_group_call_dict = {}

# variables for setting detection group names
var melee_range_group
var close_range_group
var near_range_group
var far_range_group
var distant_range_group

const DETECTION_RADIUS_SIZE = 200
const MELEE_RADIUS_MULTIPLIER = 1.0
const CLOSE_RADIUS_MULTIPLIER = 2.0
const NEAR_RADIUS_MULTIPLIER = 3.0
const FAR_RADIUS_MULTIPLIER = 4.0

# get the range range group enum name for discerning detection group names
var melee_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.MELEE]
var close_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.CLOSE]
var near_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.NEAR]
var far_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.FAR]
var distant_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.DISTANT]

var grouping_string = str(self)+"_"

# future-proofing variables for enemies with variable detection
var perception_bonus_flat_size_increase: int = 0
var perception_bonus_multiplier_melee: float = 0.0
var perception_bonus_multiplier_close: float = 0.0
var perception_bonus_multiplier_near: float = 0.0
var perception_bonus_multiplier_far: float = 0.0

# variables holding references to the detection radii nodes
onready var detection_radius_melee = $Range_Melee
onready var detection_radius_close = $Range_Close
onready var detection_radius_near = $Range_Near
onready var detection_radius_far = $Range_Far

# variables holding references to the collision shapes for detection nodes
onready var collision_radius_melee = $Range_Melee/CollisionShape2D
onready var collision_radius_close = $Range_Close/CollisionShape2D
onready var collision_radius_near = $Range_Near/CollisionShape2D
onready var collision_radius_far = $Range_Far/CollisionShape2D


###############################################################################


func _ready():
	set_collision_radii()
	set_detection_group_strings()
	set_group_call_dict()
#	print(call_range_group(GlobalVariables.RangeGroup.NEAR))

###############################################################################


# we have to set the strings for finding detection node groups
func set_detection_group_strings():
	# set the group strings
	melee_range_group = grouping_string + melee_range_string_suffix
	close_range_group = grouping_string + close_range_string_suffix
	near_range_group = grouping_string + near_range_string_suffix
	far_range_group = grouping_string + far_range_string_suffix
	distant_range_group = grouping_string + distant_range_string_suffix

# collision radii are set in code as they may be changeable
# by specific enemy subclasses
# must set the collision extents for each detection radius
func set_collision_radii():
	# each of these variables consist of a static constant that does
	# not change with each enemy sub class, and a bonus (or penalty)
	# that can be applied as an additional modifier, allowing for
	# enemies that are more or less perceptive of the player
	
	# by default an enemy detection radius only scans the player
	# body mask, for actors in the player layer
	
	# the flat detection radius
	var base_perception_radius =\
	 DETECTION_RADIUS_SIZE+perception_bonus_flat_size_increase
	# the multiplier for the melee range (closest to self)
	var melee_range_multiplier =\
	 MELEE_RADIUS_MULTIPLIER + perception_bonus_multiplier_melee
	# the multiplier for the close range (second closest to self)
	var close_range_multiplier =\
	 CLOSE_RADIUS_MULTIPLIER + perception_bonus_multiplier_close
	# the multiplier for the near range (second furthest from self)
	var near_range_multiplier =\
	 NEAR_RADIUS_MULTIPLIER + perception_bonus_multiplier_near
	# the multiplier for the far range (furthest from self)
	var far_range_multiplier =\
	 FAR_RADIUS_MULTIPLIER + perception_bonus_multiplier_far
	
	# now we set the collision extents for the collision shape
	# (circle shape) of each detection radius
	# set the melee range
	collision_radius_melee.shape.radius =\
	 base_perception_radius*melee_range_multiplier
	# set the close range
	collision_radius_close.shape.radius =\
	 base_perception_radius*close_range_multiplier
	# set the near range
	collision_radius_near.shape.radius =\
	 base_perception_radius*near_range_multiplier
	# set the far range
	collision_radius_far.shape.radius =\
	 base_perception_radius*far_range_multiplier
	
	# not listed here, as it does not have a detection radius, is
	# the 'distant' range, which is for any actor not in a range group
	# which has been detected before (i.e. the detector has some prior
	# knowledge of them)
	# the distant range is handled by the 'far' dection group
	# actors that have never been encountered are in the technical
	# 'undetected' detection group, and should not be interacted with
	# barring specific code exemptions


# sets up the call dict
# the call dict allows the function ''
# said function allows a GlobalVariables.RangeGroup constant to be passed
# and calls then returns the relevant range group
func set_group_call_dict():
	var base_group_string = "_range_group"
	var prefix_group_string
	for id in GlobalVariables.RangeGroup.keys():
		prefix_group_string = ""
		prefix_group_string = id.to_lower()
		var full_call_string = prefix_group_string+base_group_string
		var enum_id = GlobalVariables.RangeGroup[id]
		range_group_call_dict[enum_id] = full_call_string


# pass a GlobalVariables.RangeGroup constant
# get back list of nodes in said range group
func call_range_group(range_id):
#	print(range_id)
#	if range_id in GlobalVariables.RangeGroup.keys():
	var range_var_string = range_group_call_dict[range_id]
#		print(range_var_string)
	return get_tree().get_nodes_in_group(get(range_var_string))


###############################################################################


# handling when a body moves in to the melee detection radius
func _on_Range_Melee_body_entered(body):
	add_to_detection_group(GlobalVariables.RangeGroup.MELEE, body)


# handling when a body moves out of the melee detection radius
func _on_Range_Melee_body_exited(body):
	remove_from_detection_group(GlobalVariables.RangeGroup.MELEE, body)


# handling when a body moves in to the close detection radius
func _on_Range_Close_body_entered(body):
	add_to_detection_group(GlobalVariables.RangeGroup.CLOSE, body)


# handling when a body moves out of the close detection radius
func _on_Range_Close_body_exited(body):
	remove_from_detection_group(GlobalVariables.RangeGroup.CLOSE, body)


# handling when a body moves in to the near detection radius
func _on_Range_Near_body_entered(body):
	add_to_detection_group(GlobalVariables.RangeGroup.NEAR, body)


# handling when a body moves out of the near detection radius
func _on_Range_Near_body_exited(body):
	remove_from_detection_group(GlobalVariables.RangeGroup.NEAR, body)


# handling when a body moves in to the far detection radius
# if inside the far detection radius then
# the body can not also be in the distant detection radius
func _on_Range_Far_body_entered(body):
	add_to_detection_group(GlobalVariables.RangeGroup.FAR, body)
	remove_from_detection_group(GlobalVariables.RangeGroup.DISTANT, body)


# handling when a body moves out of the far detection radius
# if outside of the far detection radius then
# the body is in the distant detection radius
func _on_Range_Far_body_exited(body):
	remove_from_detection_group(GlobalVariables.RangeGroup.FAR, body)
	add_to_detection_group(GlobalVariables.RangeGroup.DISTANT, body)


# TODO
# include code for an enemy damaged by a player automatically
# adding that player to their distant detection radii if not already in it


###############################################################################


# NOTE: How do these detection radii work, and why do they exist?
# Bodies are logged to enemy_specific node groups when moving in and out
# of preset distances to the enemy
# these node groups can then be called and checked for ai programming
# i.e. 'is there a valid target for this ability within a close range,
# if so perform ability, else meander pointlessly'
# it allows for modular and straightforward AI programming

# a physics body (actor or entity) has moved into the detection radius of
# this enemy, and must be recorded as being within that range
func add_to_detection_group(range_group, body):
	# make sure we're not detecting the enemy or any non-actor
	if body != self and body != owner and body is Actor:
		emit_signal("body_changed_detection_radius", body, true, range_group)
		var range_string = GlobalVariables.RangeGroup.keys()[range_group]
		var full_range_string = grouping_string+range_string
		if GlobalDebug.enemy_detection_radii_logs: print("detection group " + full_range_string + " entered by " + body.name)
		# add body to the group denoted by radii and enemy id
		body.add_to_group(full_range_string)


# a physics body (actor or entity) has moved out of the detection radius of
# this enemy, and must be recorded as no longer being within that range
func remove_from_detection_group(range_group, body):
	# make sure we're not detecting the enemy or any non-actor
	if body != self and body != owner and body is Actor:
		emit_signal("body_changed_detection_radius", body, false, range_group)
		var range_string = GlobalVariables.RangeGroup.keys()[range_group]
		var full_range_string = grouping_string+range_string
		if GlobalDebug.enemy_detection_radii_logs: print("detection group " + full_range_string + " entered by " + body.name)
		
		# To avoid debugger error "!data.grouped.has(p_identifier)"
		# we include a check to see if body is in group
		if body.is_in_group(full_range_string):
			body.remove_from_group(full_range_string)
#
#func call_detection_group():
##	# unfinished code for calling detection groups (TODO finish)
##	var melee_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.MELEE]
##	var close_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.CLOSE]
##	var near_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.NEAR]
##	var far_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.FAR]
##	var distant_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.DISTANT]
#
#	var group_to_call = grouping_string # + pick any string above
#	#get_tree().get_nodes_in_group(group_to_call)
##	get_tree().call_group(group_to_call, do_this_method_test_example)

###############################################################################

# TODO review this code
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


# TODO review this code
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


# TODO change to use call dict
func get_closest_player_in_near_group():
	var closest_player = get_nearest_player_in_range_group(get_tree().get_nodes_in_group(near_range_group))
	if closest_player != null:
		return closest_player


# pass this function a GlobalVariables.RangeGroup constant or range group or 
# (pass call dict a GlobalVariables.RangeGroup constant to get range group)
# and a target (any actor i.e. player or enemy)
func is_actor_in_range_group(target, range_group):
	# validate passed arguments, log error if incorrect arguments passed
	# validate target arg and range_group arg
	if target is Actor and range_group in GlobalVariables.RangeGroup\
	or target is Actor and range_group is Array:
		# if range_group was passed a GV.RangeGroup constant, create array
		# note: if passed array we're trusting the calling function to pass
		# an array with nodes in, else this will return false
		if range_group in GlobalVariables.RangeGroup:
			# set range_group var as the array of nodes in said range group
			# using the group call dict
			range_group = call_range_group(range_group)
		# validated range_group arg successfully, carry on
		# return the bool statement of whether target is in the array
		return target in range_group
	else:
		if GlobalDebug.enemy_detection_func_logs: print("function [is_actor_in_range_group] exception")

