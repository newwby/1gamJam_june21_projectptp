extends CPUParticles2D

# effect stores original speeds for resetting
var entity_original_speed
var entity_original_rotation_speed
#	target.rotation_per_tick = original_rotation_speed

var time_slow_particle_effect = self

var action_speed_multiplier = 0.25

var particle_amount_on_actor = 10
var particle_scale_on_actor = 0.05
var particle_emission_radii_on_actor = 75

var particle_amount_on_projectile = 5
var particle_scale_on_projectile = 0.025
var particle_emission_radii_on_projectile = 25

###############################################################################


# Called when the node enters the scene tree for the first time.
# activates effect of time slow
func _ready():
	set_initial_timeslow()


###############################################################################


# particle pattern modified depending on who parent is
func set_particle_parameters(particle_amount, particle_scale, particle_radii):
	time_slow_particle_effect.amount = particle_amount
	time_slow_particle_effect.scale_amount = particle_scale
	time_slow_particle_effect.emission_sphere_radius = particle_radii


###############################################################################


# function for calling time slow effect behaviour funcs
func set_initial_timeslow():
	# get which func to call based on what node type we are affecting
	var parent_node = get_parent()
	if parent_node is Actor:
		set_particle_parameters(particle_amount_on_actor,\
		particle_scale_on_actor, particle_emission_radii_on_actor)
		set_initial_timeslow_on_actor(parent_node)
	elif parent_node is Projectile:
		set_particle_parameters(particle_amount_on_projectile,\
		particle_scale_on_projectile, particle_emission_radii_on_projectile)
		set_initial_timeslow_on_projectile(parent_node)


###############################################################################


func set_initial_timeslow_on_actor(affected_node):
	# store speed
	entity_original_speed = affected_node.movement_speed
	# calculate new speed, then set
	var new_speed = entity_original_speed * action_speed_multiplier
	affected_node.movement_speed = new_speed


func set_initial_timeslow_on_projectile(affected_node):
	# store speed and rotation
	entity_original_speed = affected_node.projectile_speed
	entity_original_rotation_speed = affected_node.rotation_per_tick
	# calculate new speed and rotation, then set
	var new_speed = entity_original_speed * action_speed_multiplier
	var new_rotation = entity_original_rotation_speed * action_speed_multiplier
	affected_node.projectile_speed = new_speed
	affected_node.rotation_per_tick = new_rotation


###############################################################################


# function for finding correct func to revert the effect of the time slow
func end_timeslow():
	# stop particle emission
	time_slow_particle_effect.emitting = false
	# get which func to call based on what node type we are affecting
	var parent_node = get_parent()
	if parent_node is Actor:
		end_timeslow_on_actor(parent_node)
	elif parent_node is Projectile:
		end_timeslow_on_projectile(parent_node)


###############################################################################


func end_timeslow_on_actor(affected_node):
	# reset speed
	affected_node.movement_speed = entity_original_speed
	queue_free()


func end_timeslow_on_projectile(affected_node):
	# reset speed and rotation
	affected_node.projectile_speed = entity_original_speed
	affected_node.rotation_per_tick = entity_original_rotation_speed
	queue_free()
