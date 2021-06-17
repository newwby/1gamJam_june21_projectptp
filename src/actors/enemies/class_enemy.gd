
class_name Enemy
extends Actor

enum State{
	IDLE,
	PATROL,
	HUNT,
	ATTACK,
	HURT,
	DYING
}

const DETECTION_RADIUS_SIZE = 300
const MELEE_RADIUS_MULTIPLIER = 1.0
const CLOSE_RADIUS_MULTIPLIER = 2.0
const NEAR_RADIUS_MULTIPLIER = 3.0
const FAR_RADIUS_MULTIPLIER = 4.0

const ENEMY_TYPE_BASE_MOVEMENT_SPEED = 150

var is_active = true
var can_check_state = true

# the current state the enemy is in
var current_state
# states that the enemy was previously in that still need to be resolved
var state_register = []

# future-proofing variables for enemies with variable detection
var perception_bonus_flat_size_increase: int = 0
var perception_bonus_multiplier_melee: float = 0.0
var perception_bonus_multiplier_close: float = 0.0
var perception_bonus_multiplier_near: float = 0.0
var perception_bonus_multiplier_far: float = 0.0


# get the range range group enum name for discerning detection group names
var melee_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.MELEE]
var close_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.CLOSE]
var near_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.NEAR]
var far_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.FAR]
var distant_range_string_suffix = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.DISTANT]

# variables for setting detection group names
var melee_range_group
var close_range_group
var near_range_group
var far_range_group
var distant_range_group

# TODO sort out enemy sprite auto scaling

var grouping_string = str(self)+"_"

# variables holding references to the detection radii nodes
onready var detection_radius_melee = $DetectionRadiiHolder/Range_Melee
onready var detection_radius_close = $DetectionRadiiHolder/Range_Close
onready var detection_radius_near = $DetectionRadiiHolder/Range_Near
onready var detection_radius_far = $DetectionRadiiHolder/Range_Far

# variables holding references to the collision shapes for detection nodes
onready var collision_radius_melee = $DetectionRadiiHolder/Range_Melee/CollisionShape2D
onready var collision_radius_close = $DetectionRadiiHolder/Range_Close/CollisionShape2D
onready var collision_radius_near = $DetectionRadiiHolder/Range_Near/CollisionShape2D
onready var collision_radius_far = $DetectionRadiiHolder/Range_Far/CollisionShape2D

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("enemies")
	set_enemy_stats()
	set_collision_radii()
	set_detection_group_strings()
	set_initial_state(State.IDLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_check_state:
		_process_check_state()
	_process_call_state_behaviour(delta)
	move_and_slide(velocity.normalized() * movement_speed)

###############################################################################


	# this is a call function for state behaviour
func _process_call_state_behaviour(_dt):
	# check state and move to that function
	match current_state:
	
		# enemy is idle and doing nothing
		State.IDLE:
			# state_idle()
			pass
	
		# enemy is wandering aimlessly or following a patrol route
		State.PATROL:
			# state_wander_aimlessly()
			pass
	
		# enemy is hunting a player
		State.HUNT:
			# state_hunt()
			pass
	
		# enemy is in range of a target and is initiating an attack
		State.ATTACK:
			# state_attack()
			pass
	
		# enemy has been injured and is playing hurt animation/logic
		State.HURT:
			# state_hurt()
			pass
	
		# enemy has been injured so much they are dying
		State.DYING:
			# state_dying()
			pass


# check whether we can change state
func _process_check_state():
	# if enemy is doing nothing and isn't already idle, set to idle
	if not is_active\
	 and current_state != State.IDLE\
	 and state_register.size() == 0:
		set_new_state(State.IDLE)
	
	# TODO re-enable state register, not currently using it
	# if we have previous states to handle, handle them!
#	if state_register.size() > 0:
#		if state_register[0] in State:
#			current_state = state_register.pop_front()

	# if no target look for one
	var potential_targets = []
	var nodes_at_far_range = get_tree().get_nodes_in_group(close_range_group)
	
	# check if player is visible
	
	# scan all valid targets
	for i in nodes_at_far_range:
		if i is Player:
			potential_targets.append(i)
	
# func GlobalFunc.GetNearestInArray():
	# clear these variables
	var closest_target = null
	var closest_target_distance = null
	# check who is the closest valid target
	if potential_targets.size() > 0:
		for i in potential_targets:
			var get_distance = position.distance_to(i.position)
			# if haven't set
			if closest_target_distance == null:
				closest_target_distance = get_distance
				closest_target = i
			elif get_distance < closest_target_distance:
				closest_target_distance = get_distance
				closest_target = i
	
	if closest_target != null:
		velocity = -(position - closest_target.position)

###############################################################################


func set_enemy_stats():
	movement_speed = ENEMY_TYPE_BASE_MOVEMENT_SPEED


# set the first state and clear the state register
func set_initial_state(starting_state):
	state_register = []
	current_state = starting_state


# change our state
func set_new_state(new_state):
	state_register.append(current_state)
	current_state = new_state


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
	if body != self:
		var range_string = GlobalVariables.RangeGroup.keys()[range_group]
		var full_range_string = grouping_string+range_string
		if GlobalDebug.enemy_detection_radii_logs: print("detection group " + full_range_string + " entered by " + body.name)
		# add body to the group denoted by radii and enemy id
		body.add_to_group(full_range_string)


# a physics body (actor or entity) has moved out of the detection radius of
# this enemy, and must be recorded as no longer being within that range
func remove_from_detection_group(range_group, body):
	if body != self:
		var range_string = GlobalVariables.RangeGroup.keys()[range_group]
		var full_range_string = grouping_string+range_string
		if GlobalDebug.enemy_detection_radii_logs: print("detection group " + full_range_string + " entered by " + body.name)
		
		# To avoid debugger error "!data.grouped.has(p_identifier)"
		# we include a check to see if body is in group
		if body.is_in_group(full_range_string):
			body.remove_from_group(full_range_string)


func call_detection_group():
#	# unfinished code for calling detection groups (TODO finish)
#	var melee_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.MELEE]
#	var close_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.CLOSE]
#	var near_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.NEAR]
#	var far_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.FAR]
#	var distant_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.DISTANT]
	
	var group_to_call = grouping_string # + pick any string above
	#get_tree().get_nodes_in_group(group_to_call)
#	get_tree().call_group(group_to_call, do_this_method_test_example)
