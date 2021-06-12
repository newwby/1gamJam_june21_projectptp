

class_name Projectile
extends Area2D

# constant float for modifying velocity inherited from spawner
const INHERITED_VELOCITY_MULTIPLIER := 0.5

# TODO investigate old shooter prototype I made and how I implemented
# burst fire/projectile spread

# coloUr code for modulate. of the sprite
# default white
var projectile_colour_code = Color.white

# projectile is sized according to this variable
var projectile_set_size = 1.0
# projectile collision area uses this base value
var projectile_collision_base_radius = 28
# projectile records where it spawned
var starting_position = Vector2(0,0)
# projectile deletes itself if it travels further than this from spawn
var maximum_range = 800
# projectile deletes itself if it moves for more than this many ticks
var current_ticks_has_moved = 0
var maximum_ticks_moving = 10000

# how fast the projectile rotates each tick
var rotation_per_tick

# projectile moves at this rate
var projectile_speed = 1600
# projectile is allowed to move
var is_projectile_movement_allowed = true
# projectile moved this tick
var is_projectile_moving_this_tick = true

# simplified velocity
var velocity = Vector2.ZERO

# defunct?
# final projectile movement vector
var projectile_travel_vector = Vector2.ZERO
# projectile travels this direction multiplied by its speed
var facing_direction = Vector2.ZERO
# initial speed of the attacker passed at spawn
var initial_velocity = Vector2.ZERO

# projectile deletes itself if its lifespan (set at instantiation) expires
var projectile_lifespan := 5.0
# projectile has this much of a grace period once offscreen before deletion
var offscreen_lifespan := 1.0

var projectile_sprite_path

# array of every sprite involved with the projectile
onready var projectile_sprite_holder = $SpriteHolder
# sprite handler replaced with simple sprite
onready var simple_sprite = $SpriteHolder/ProjectileSprite

# nodes in the projectile
onready var projectile_collision = $ProjectileCollision
onready var projectile_life_timer = $ProjectileLifespan

###############################################################################


# Called when the node enters the scene tree for the first time.
# set projectile extents, timer values, range
func _ready():
	setup_collision_and_sprite_size()
	setup_projectile_lifespan_timer()
	setup_maximum_projectile_range()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_process_handle_movement(delta)
	_process_rotate_self(delta)


##############################################################################


# simplified movement instructions
func _process_rotate_self(dt):
	for i in projectile_sprite_holder.get_children():
		i.rotation_degrees += rotation_per_tick

# simplified movement instructions
func _process_handle_movement(dt):
	if is_projectile_movement_allowed and is_projectile_moving_this_tick:
		self.position += velocity * dt * projectile_speed
		_process_ticks_travelled(dt)


# projectile moves according to given vector instruction
func defunct_process_handle_movement(dt):
	if is_projectile_movement_allowed and is_projectile_moving_this_tick:
		# clear previous vector
		#projectile_travel_vector = Vector2.ZERO
		# apply initial velocity, then add facing multiplied by speed
		projectile_travel_vector = \
		initial_velocity * INHERITED_VELOCITY_MULTIPLIER + \
		(facing_direction * projectile_speed)
		# adjust own position by ticks since last calculation
		self.position += projectile_travel_vector * dt
		_process_ticks_travelled(dt)


# if projectile travels for more ticks than it is allowed, delete it
func _process_ticks_travelled(dt):
	current_ticks_has_moved += dt
	if current_ticks_has_moved >= maximum_ticks_moving:
		if GlobalDebug.projectile_exit_logging: print("projectile ", self.name, " deleting self due to max ticks travelled")
		call_projectile_expiry()


##############################################################################


# initial setup of collision size and sprite size
func setup_collision_and_sprite_size():
	# no longer necessary
#	var set_size_as_vector = Vector2(projectile_set_size, projectile_set_size)
	set_projectile_scale()

# sets the collision and projectile size
func set_projectile_scale():
	# if the projectile is size modified, also modify the collision area
	simple_sprite.scale =\
	 Vector2(projectile_set_size, projectile_set_size)
	projectile_collision.shape.radius =\
	 projectile_collision_base_radius * projectile_set_size
	# set sprite
	if projectile_sprite_path != null:
		simple_sprite.texture = load(projectile_sprite_path)
	simple_sprite.modulate = projectile_colour_code


# NOW DEFUNCT, this is the original func I used for testing
# projectile collision is set according to var projectile_set_size
func defunct_setup_collision_extents(given_vector):
	projectile_collision.shape.extents = given_vector

# NOW DEFUNCT, this is the original func I used for testing
# sprite holder node contains animated sprites that make up projectile graphics
# this function assigns a scale adjustment to all children of that node
# scale adjustment is  set according to var projectile_set_size
func defunct_setup_sprite_size(size_to_set):
	# sprite scale adjustment set to default
	var set_sprite_scale = Vector2(1.0, 1.0)
	
	# if node in sprite holder node is animated sprite
	# set to adjusted value and play
	for anim_sprite in projectile_sprite_holder.get_children():
		if anim_sprite is AnimatedSprite:
			set_sprite_scale = Vector2(0.15, 0.15)
			anim_sprite.scale = set_sprite_scale
			anim_sprite.playing = true
			if GlobalDebug.proj_sprite_handling: print(anim_sprite.name, "set")


# if the projectile is spawned the lifespan timer is assigned a given
# wait time value (according to var projectile_lifespan) and started
func setup_projectile_lifespan_timer():
	projectile_life_timer.wait_time = projectile_lifespan
	projectile_life_timer.start()


# to determine how far the projectile has travelled from its original
# position we need to record that position
func setup_maximum_projectile_range():
	starting_position = self.position


##############################################################################


# if the timer for the projectile's lifespan expires, delete the projectile
func _on_ProjectileLifespan_timeout():
	if GlobalDebug.projectile_exit_logging: print("projectile ", self.name, " deleting self due to lifespan timer")
	call_projectile_expiry()


# if the projectile exits the screen, consider whether to delete it
func _on_ProjectileVisibilityNotifier_screen_exited():
	var life_time_left = projectile_life_timer.time_left
	var life_cutoff = offscreen_lifespan
	# if projectile has less than it's grace period left, immediately delete
	if life_time_left <= life_cutoff:
		if GlobalDebug.projectile_exit_logging: print("projectile ", self.name, " deleting self due to offscreen timer")
		call_projectile_expiry()
	else:
		# otherwise the remaining duration is set to the grace period
		projectile_life_timer.stop()
		projectile_life_timer.wait_time = life_cutoff
		projectile_life_timer.start()


##############################################################################


# whenever you feel ready to delete this safely godot, go for it
func call_projectile_expiry():
	queue_free()
