
class_name Actor
extends KinematicBody2D

# this is the movement rate per tick of the actor
var movement_speed = 400
# this is the actor's current velocity
var velocity: Vector2 = Vector2.ZERO
# this is the last direction the actor moved and changed facing
var last_facing = Vector2(0,0)


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_handle_movement(delta)

# by default actors have no movement handling
# movement handling has to be declared in child classes
func process_handle_movement(_dt):
	pass


###############################################################################

