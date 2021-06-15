
class_name enemy
extends Actor

const DETECTION_RADIUS_SIZE = 300
const MELEE_RADIUS_MULTIPLIER = 1.0
const CLOSE_RADIUS_MULTIPLIER = 2.0
const NEAR_RADIUS_MULTIPLIER = 3.0
const FAR_RADIUS_MULTIPLIER = 4.0

# future-proofing variables for enemies with variable detection
var perception_bonus_flat_size_increase: int = 0
var perception_bonus_multiplier_melee: float = 0.0
var perception_bonus_multiplier_close: float = 0.0
var perception_bonus_multiplier_near: float = 0.0
var perception_bonus_multiplier_far: float = 0.0

# TODO sort out enemy auto scaling

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
	set_collision_radii()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
		body.add_to_group(full_range_string)


# a physics body (actor or entity) has moved out of the detection radius of
# this enemy, and must be recorded as no longer being within that range
func remove_from_detection_group(range_group, body):
	if body != self:
		var range_string = GlobalVariables.RangeGroup.keys()[range_group]
		var full_range_string = grouping_string+range_string
		if GlobalDebug.enemy_detection_radii_logs: print("detection group " + full_range_string + " entered by " + body.name)
		body.remove_from_group(full_range_string)


func call_detection_group():
	# unfinished code for calling detection groups (TODO finish)
	var melee_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.MELEE]
	var close_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.CLOSE]
	var near_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.NEAR]
	var far_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.FAR]
	var distant_range_string = GlobalVariables.RangeGroup.keys()[GlobalVariables.RangeGroup.DISTANT]
	
	var group_to_call = grouping_string # + pick any string above
	#get_tree().get_nodes_in_group(group_to_call)
#	get_tree().call_group(group_to_call, do_this_method_test_example)
