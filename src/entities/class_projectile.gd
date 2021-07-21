

class_name Projectile
extends Area2D

signal projectile_expired # DEBUGGER ISSUE, UNUSED

# constant float for modifying velocity inherited from spawner
const INHERITED_VELOCITY_MULTIPLIER := 0.5

var projectile_owner

# colour code for modulate. of the sprite
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
var projectile_damage = 10

# projectile moves at this rate
var projectile_speed = 1600
# projectile is allowed to move
var is_projectile_movement_allowed = true
# projectile moved this tick
var is_projectile_moving_this_tick = true

# simplified velocity
var velocity = Vector2.ZERO
#
# projectile travels this direction multiplied by its speed
var facing_direction = Vector2.ZERO
# initial speed of the attacker passed at spawn
var initial_velocity = Vector2.ZERO

# projectile deletes itself if its lifespan (set at instantiation) expires
var projectile_lifespan := 5.0
# projectile has this much of a grace period once offscreen before deletion
var offscreen_lifespan := 1.0

# duration of the fade tween once started (progression of full alpha to 0)
var projectile_expiry_fade_duration := 0.25

# initialisated by projectile instantiation
var projectile_movement_behaviour

# projectile graphic/sprite texture path (initialised in code)
var projectile_sprite_path

# enum for weapon.particle
var projectile_particle_id

var base_orbit_distance_from_player = 300
# disabled, used to be used for weird big planet esque orbit chaos
var orbit_variance_multiplier = 0

# array of every sprite involved with the projectile
onready var projectile_sprite_holder = $SpriteHolder
# sprite handler replaced with simple sprite
onready var simple_sprite = $SpriteHolder/ProjectileSprite
onready var simple_sprite_undershadow = $SpriteHolder/ProjectileSprite/ProjectileSpriteShadow

# nodes in the projectile
onready var projectile_collision = $ProjectileCollision
onready var projectile_life_timer = $ProjectileLifespan

onready var orbital_particles = $ProjectileParticlesOrbital
onready var heavy_particles = $ProjectileParticlesHeavy

# tween for projectile expiry/fading
onready var fading_tween = $FadeTween


###############################################################################


# Called when the node enters the scene tree for the first time.
# set projectile extents, timer values, range
func _ready():
	self.add_to_group("projectiles")
	set_collision_and_sprite_size()
	set_projectile_lifespan_timer()
	set_particle_effects()
	set_orbit_and_radar()
	set_maximum_projectile_range()
	set_collision_layers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_process_handle_movement(delta)
	_process_rotate_self(delta)


##############################################################################


# simplified movement instructions
func _process_rotate_self(_dt):
	self.rotation_degrees += rotation_per_tick
#	for i in projectile_sprite_holder.get_children():
#		i.rotation_degrees += rotation_per_tick


# simplified movement instructions
func _process_handle_movement(dt):
	if is_projectile_movement_allowed and is_projectile_moving_this_tick:
		self.position += velocity * dt * projectile_speed
		_process_ticks_travelled(dt)


# if projectile travels for more ticks than it is allowed, delete it
func _process_ticks_travelled(dt):
	current_ticks_has_moved += dt
	if current_ticks_has_moved >= maximum_ticks_moving:
		if GlobalDebug.projectile_exit_logging: print("projectile ", self.name, " deleting self due to max ticks travelled")
		begin_projectile_expiry()


##############################################################################


# setup collision for projectile
func set_collision_layers():
	
	# projectiles should only ever be spawned by readied actors
	if projectile_owner is Actor:
		set_collision_mask_bit(\
		GlobalVariables.CollisionLayers.EFFECT, true)
		#
		# if projectile is spawned by a player actor
		if projectile_owner is Player:
			# player entity, or 1
			set_collision_layer_bit(\
			GlobalVariables.CollisionLayers.PLAYER_ENTITY, true)
			# enemy body, or 2
			set_collision_mask_bit(\
			GlobalVariables.CollisionLayers.ENEMY_BODY, true)
		#
		# if projectile is spawned by an enemy actor
		elif projectile_owner is Enemy:
			# enemy entity, or 3
			set_collision_layer_bit(\
			GlobalVariables.CollisionLayers.ENEMY_ENTITY, true)
			# player body, or 0
			set_collision_mask_bit(\
			GlobalVariables.CollisionLayers.PLAYER_BODY, true)
	


# initial setup of collision size and sprite size
func set_collision_and_sprite_size():
	# no longer necessary
#	var set_size_as_vector = Vector2(projectile_set_size, projectile_set_size)
	set_projectile_scale()


# sets the collision and projectile size
func set_projectile_scale():
	var projectile_modified_scale
	projectile_modified_scale = projectile_set_size

	# Modify projectile based on player or enemy ownership
	# Player projectiles are bigger
	# Enemy projectiles are smaller
#	print(projectile_owner)
	if projectile_owner is Player:
		projectile_modified_scale *= 1.10
	elif projectile_owner is Enemy:
		projectile_modified_scale *= 0.80
		
	# if the projectile is size modified, also modify the collision area
	simple_sprite.scale =\
	 Vector2(projectile_modified_scale, projectile_modified_scale)
	simple_sprite_undershadow.scale =\
	 Vector2(projectile_modified_scale, projectile_modified_scale)
	projectile_collision.shape.radius =\
	 projectile_collision_base_radius * projectile_modified_scale
	
	# set sprite
	if projectile_sprite_path != null:
		simple_sprite.texture = load(projectile_sprite_path)
		simple_sprite_undershadow.texture = load(projectile_sprite_path)
	simple_sprite.modulate = projectile_colour_code

	# Modify projectile based on player or enemy ownership
	# Player projectiles are darker/faded
	# Enemy projectiles are lighter/clearer
	if projectile_owner is Player:
		simple_sprite.modulate.a -= 0.1
		simple_sprite.modulate.r += 0.2
		simple_sprite.modulate.g += 0.2
		simple_sprite.modulate.b += 0.2
	elif projectile_owner is Enemy:
		simple_sprite.modulate.a += 0.1
		simple_sprite.modulate.r -= 0.2
		simple_sprite.modulate.g -= 0.2
		simple_sprite.modulate.b -= 0.2
		projectile_speed *= 0.75


# if the projectile is spawned the lifespan timer is assigned a given
# wait time value (according to var projectile_lifespan) and started
func set_projectile_lifespan_timer():
	projectile_life_timer.wait_time = projectile_lifespan
	projectile_life_timer.start()


# if using certain weapon sets enable particles else disable
func set_particle_effects():
	# set default
	orbital_particles.visible = false
	orbital_particles.emitting = false
	heavy_particles.visible = false
	heavy_particles.emitting = false
		
	# orbital weapon particles
	if projectile_particle_id == 1:
		orbital_particles.visible = true
		orbital_particles.emitting = true
	# heavy shot weapon particles
	elif projectile_particle_id == 2:
		heavy_particles.visible = true
		heavy_particles.emitting = true


# initialise handling orbit and orbit-related projectile movement
func set_orbit_and_radar():
	if projectile_movement_behaviour == GlobalVariables.ProjectileMovement.ORBIT:
		start_projectile_orbit()
	elif projectile_movement_behaviour == GlobalVariables.ProjectileMovement.RADAR:
		start_projectile_radar_sweep()


# to determine how far the projectile has travelled from its original
# position we need to record that position
func set_maximum_projectile_range():
	starting_position = self.position


##############################################################################

func _on_Projectile_body_entered(body):
	if body is Actor and body != projectile_owner:
		if body.is_active:
			if body is Player and not body.is_damageable_by_foes:
				return
			else:
				body.emit_signal("damaged", projectile_damage, projectile_owner)
				call_projectile_expiry()


###############################################################################


# if the timer for the projectile's lifespan expires, delete the projectile
func _on_ProjectileLifespan_timeout():
	if GlobalDebug.projectile_exit_logging: print("projectile ", self.name, " deleting self due to lifespan timer")
	begin_projectile_expiry()


# if the projectile exits the screen, consider whether to delete it
func _on_ProjectileVisibilityNotifier_screen_exited():
	var life_time_left = projectile_life_timer.time_left
	var life_cutoff = offscreen_lifespan
	# if projectile has less than it's grace period left, immediately delete
	if life_time_left <= life_cutoff:
		if GlobalDebug.projectile_exit_logging: print("projectile ", self.name, " deleting self due to offscreen timer")
		begin_projectile_expiry()
	else:
		# otherwise the remaining duration is set to the grace period
		projectile_life_timer.stop()
		projectile_life_timer.wait_time = life_cutoff
		projectile_life_timer.start()


##############################################################################




func _on_FadeTween_tween_completed(_object, _key):
	call_projectile_expiry()

func _on_FadeTween_tween_all_completed():
	queue_free()


# defunct, remove?
# if orbital behaviour timer elapses we must set the projectile
# to rotate around the orbital handler node of the projectile owner
func _on_OrbitInitialisationTimer_timeout():
	# make sure projectile owner has been set
	if projectile_owner != null:
		pass
		# parent swap must be set up
#		var old_parent = get_parent()
#		var new_parent = projectile_owner
#		var parent_trap = starring_lindsay_lohan
		
		# stop projectile motion and stop it moving further away?
#		position = Vector2(20,0)
#		velocity = Vector2.ZERO
#		is_projectile_movement_allowed = false
		
#		old_parent.remove_child(self)
		
#		if projectile_movement_behaviour == GlobalVariables.ProjectileMovement.RADAR:
#			var set_new_position = get_parent().position-position
##			position = set_new_position
##			rotation = set_new_position.angle()
#			print(get_parent().position)
#			print(position)
#		elif projectile_movement_behaviour == GlobalVariables.ProjectileMovement.ORBIT:
#			print("orbit")
		
#		new_parent.orbit_handler_node.add_child(self)


##############################################################################


func start_projectile_orbit():
	var get_active_projectiles = get_parent().get_child_count()
	
	# vary the orbit
	var orbit_distance_floor =\
	 base_orbit_distance_from_player * (1-orbit_variance_multiplier)
	var orbit_distance_ceiling =\
	 base_orbit_distance_from_player * (1+orbit_variance_multiplier)
	var orbit_distance = GlobalFuncs.ReturnRandomRange(orbit_distance_floor, orbit_distance_ceiling)
	
	position = Vector2(0, orbit_distance*get_active_projectiles)
#	rotation_degrees = 45*get_active_projectiles
	velocity = Vector2.ZERO
	is_projectile_movement_allowed = false


func start_projectile_radar_sweep():
#	print("radsweep")
	position = Vector2.ZERO
#	velocity = Vector2.ZERO
#	is_projectile_movement_allowed = false


##############################################################################


# begin a tween to fade projectile away rapidly
func begin_projectile_expiry():
#	call_projectile_expiry()
	if fading_tween.is_inside_tree():
		fading_tween.interpolate_property(self,\
		 "modulate:a", modulate.a, 0, projectile_expiry_fade_duration,\
		 Tween.TRANS_LINEAR, Tween.EASE_OUT)
		fading_tween.start()


# whenever you feel ready to delete this safely godot, go for it
func call_projectile_expiry():
	emit_signal("projectile_expired")
	queue_free()


##############################################################################
