
class_name Actor
extends KinematicBody2D

signal damaged

# this is the movement rate per tick of the actor
var movement_speed = 400
# this is the actor's current velocity
var velocity: Vector2 = Vector2.ZERO
# this is the last direction the actor moved and changed facing
var last_facing = Vector2(0,0)
# check if the actor is moving or not, has to be set on the sub-class
# i.e. player or enemy
var is_moving = false

# does the actor have a targeting sprite
var has_target_sprite = true
# is the player allowed to rotate their target sprite
var can_rotate_target_sprites = true
# are we showing all targeting sprites
var show_rotate_target_sprites = true


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("actors")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_handle_movement(delta)

# by default actors have no movement handling
# movement handling has to be declared in child classes
func process_handle_movement(_dt):
	pass


###############################################################################

