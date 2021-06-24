
class_name LeafSpriteController, "res://art/kenney_world_sprites/abstract-platformer-370-assets/PNG/Other/plantTop_leaves.png"
extends Node2D

# reference a string path held elsewhere (for simpler path changes)
const LEAF_PATH = GlobalReferences.windy_leaf_particle

var leaf_spawn_position

# how fast are new leaves spawned
var spawn_delay = 1.0
# where do leaves start

# leaf movement direction override for spawning
var leaf_direction = Vector2(0.5, 0.5)
var velocity_range = 0.5

# resource path of the projectile actors can spawn
onready var leaf_object = preload(LEAF_PATH)
onready var leaf_timer = $TimerController

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spawn_rate_of_leaves()
	leaf_spawn_position = Vector2(\
	self.position.x-5,\
	self.position.y-5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


func _on_TimerController_timeout():
	spawn_new_leaf()


###############################################################################


# set up and control the timer for spawning (self)
func set_spawn_rate_of_leaves():
	leaf_timer.wait_time = spawn_delay
	leaf_timer.autostart = true
	leaf_timer.one_shot = false
	if leaf_timer.is_stopped():
		leaf_timer.start()


func spawn_new_leaf():
	var new_leaf = leaf_object.instance()
	new_leaf.position = leaf_spawn_position
	new_leaf.velocity = set_velocity_variance()
	self.add_child(new_leaf)


# give the velocity some adjustment so it looks less uniform
func set_velocity_variance():
	var vel_range_floor_x = leaf_direction.x - velocity_range
	var vel_range_ceiling_x = leaf_direction.x + velocity_range
	var vel_range_floor_y = leaf_direction.y - velocity_range
	var vel_range_ceiling_y = leaf_direction.y + velocity_range
	
	var velocity_to_set =\
	 Vector2(\
	GlobalFuncs.ReturnRandomRange(vel_range_floor_x, vel_range_ceiling_x),\
	GlobalFuncs.ReturnRandomRange(vel_range_floor_y, vel_range_ceiling_y)\
	)
	
	return velocity_to_set.normalized()

###############################################################################
