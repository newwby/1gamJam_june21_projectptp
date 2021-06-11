

class_name WeaponAbility
extends BaseAbility

# this is the temporary faux-json for data storage on weapon behaviours
var weapon = preload("res://src/technical/abilities/json_weapon_styles.gd")

# reference a string path held elsewhere (for simpler path changes)
const PROJECTILE_PATH = GlobalReferences.default_projectile

var current_weapon_style

# damage dealt by a single instance of the attack
var base_damage: int = 1

# position instructions for spawning projectiles
var projectile_spawning_pattern
# intermission between shots
# additive per shot (so time diff between 1 and 2 is same as 3 and 4)
var spawn_delay_per_shot: float

# base vector heading for projectiles spawned
# spawn patterns will vary this in their own code
var shot_velocity: Vector2 = Vector2.ZERO
# projectiles travel this fast
var shot_flight_speed: int = 100
# projectile sprites are rotated per tick if set to anything other than 0
var shot_rotation: int = 0

# number of projectiles fired
var projectile_count: int = 1
# variance for projectile spread
# initial value
var shot_spread: float = 0.15

# resource path of the projectile actors can spawn
onready var projectile_object = preload(PROJECTILE_PATH)


###############################################################################


# TODO connect projectiles spawned by ability to owner of ability
# signal for expiry initially, include others later

# TODO set collision layers based on collision layers of spawner
#	GlobalReferences.CollisionLayers.PLAYER_PROJECTILE
#	GlobalReferences.CollisionLayers.ENEMY_PROJECTILE
##		projectile.set_collision_layer_bit(index)

# TODO - need to add these to projectile instances
#		DataType.BASE_DAMAGE				: 12,
##		DataType.PROJECTILE_FLIGHT_SPEED	: 250,
##		DataType.PROJECTILE_SPRITE_TYPE	: ProjectileSprite.MAGICAL,
##		DataType.PROJECTILE_SPRITE_ROTATE	: 0,
##		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
##		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.DIRECT,
#
## TODO - need to add these to weapon ability nodes
##		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
##		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
##		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
##		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
#
## TODO - include this in spawn pattern logic
##		DataType.PROJECTILE_SPAWN_DELAY	: 0,
##		DataType.PROJECTILE_COUNT			: 1,
##		DataType.PROJECTILE_SHOT_SPREAD	: 0.05,
#
################################################################################
#
#
# Called when the node enters the scene tree for the first time.
func _ready():
	current_weapon_style = get_weapon_style(weapon.Style.SNIPER_SHOT)
	set_new_cooldown_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#
#
################################################################################
#
#
# everything the weapon node needs to know about handling projectiles
# is included in the data returned with this function
# when changing weapon (e.g. via pickup) use this function
func get_weapon_style(new_weapon_style):
	# current_weapon_style should be set to the enum weapon.Style
	# pulls from weapon.STYLE_DATA and populates ability data dict
	var ability_data
	match new_weapon_style:
		weapon.Style.SPLIT_SHOT :
			ability_data = weapon.STYLE_DATA[weapon.Style.SPLIT_SHOT]
		weapon.Style.TRIPLE_BURST_SHOT :
			ability_data = weapon.STYLE_DATA[weapon.Style.TRIPLE_BURST_SHOT]
		weapon.Style.SNIPER_SHOT :
			ability_data = weapon.STYLE_DATA[weapon.Style.SNIPER_SHOT]
		weapon.Style.RAPID_SHOT :
			ability_data = weapon.STYLE_DATA[weapon.Style.RAPID_SHOT]
		weapon.Style.HEAVY_SHOT :
			ability_data = weapon.STYLE_DATA[weapon.Style.HEAVY_SHOT]
		weapon.Style.VORTEX_SHOT :
			ability_data = weapon.STYLE_DATA[weapon.Style.VORTEX_SHOT]
	return ability_data
#
#
################################################################################
#
#
func set_new_cooldown_timer():
	activation_cooldown =\
	current_weapon_style[weapon.DataType.SHOT_USE_COOLDOWN]
	activation_timer.stop()
	setup_cooldown_timer()


# TODO add more weapon ability variations
# basic weapon ability 
func activate_ability():
	#spawn_new_projectile(projectile_object.instance(), owner.position, owner.velocity)
	call_projectile_spawn_pattern_function()
#
##my_area.set_collision_mask_bit(Layer.WALLS, true)
#
################################################################################
#
func call_projectile_spawn_pattern_function():
	# projectiles are spawned travelling in the direction of last facing
	# additionally spawner velocity is added to the projectile
	var current_weapon_spawn_pattern = \
	current_weapon_style[weapon.DataType.PROJECTILE_SPAWN_PATTERN]

	match current_weapon_spawn_pattern:
		weapon.SpawnPattern.SPREAD:
			call_spawn_pattern_spread()
		weapon.SpawnPattern.SERIES:
			call_spawn_pattern_spread()
		weapon.SpawnPattern.SNIPER:
			call_spawn_pattern_spread()



func call_spawn_pattern_spread():
	# TODO implement handling for 
	# use our current weapon style to get the number of projectiles fired
	var get_projectile_count = \
	current_weapon_style[weapon.DataType.PROJECTILE_COUNT]
#
#	# get the rotation applied to velocity for spread shots
	var base_projectile_spread = weapon.SPREAD_PATTERN_WIDTH

	var projectile_spread_increment = (weapon.SPREAD_PATTERN_WIDTH * 0.75)
##
#	# get our position for spawn origin
	var get_spawn_origin = owner.position
	# initial velocity determined by the actor
	# specifically by the actor's 'firing_target'
	# for a player it is a vector toward their mouse position
	# (at the time they pressed the fire key)
	# for any AI it is the actor or entity they are aiming at
	# (after introducing some fake 'poor aim' and/or 'aiming delay')
	var given_velocity = get_projectile_initial_velocity()
	# adjusted velocity is the velocity accounting for projectile spread
	var adjusted_velocity
	# this is to store the total rotation applied to projectile velocity
	var total_spread_increment_counter
	
	spawn_new_projectile(get_spawn_origin, given_velocity)

func overridden_call_spawn_pattern_spread():
	# TODO implement handling for 
	# use our current weapon style to get the number of projectiles fired
	var get_projectile_count = \
	current_weapon_style[weapon.DataType.PROJECTILE_COUNT]
#
#	# get the rotation applied to velocity for spread shots
	var base_projectile_spread = weapon.SPREAD_PATTERN_WIDTH

	var projectile_spread_increment = (weapon.SPREAD_PATTERN_WIDTH * 0.75)
##
#	# get our position for spawn origin
	var get_spawn_origin = owner.position
	# initial velocity determined by the actor
	# specifically by the actor's 'firing_target'
	# for a player it is a vector toward their mouse position
	# (at the time they pressed the fire key)
	# for any AI it is the actor or entity they are aiming at
	# (after introducing some fake 'poor aim' and/or 'aiming delay')
	var given_velocity = get_projectile_initial_velocity()
	# adjusted velocity is the velocity accounting for projectile spread
	var adjusted_velocity
	# this is to store the total rotation applied to projectile velocity
	var total_spread_increment_counter
##
	# EVEN NUMBERS check if projectile count is even
	if get_projectile_count % 2 == 0 and not 1 == 2:
		# if it is even
		# we are going to loop a number of times equal to half projectiles
		var half_projectile_count = get_projectile_count / 2

		# limited loop counting variable
		var spawn_loop = 1
		# bwgin the loop
		while spawn_loop < half_projectile_count:

			# each loop we will adjust the velocity twice before creating
			# a new projectile with the adjusted velocity
			# the first will positively rotate the spread by the increment total
			# the second will negatively rotate the spread by the increment total
			adjusted_velocity = given_velocity.rotated(projectile_spread_increment)
			spawn_new_projectile(get_spawn_origin, adjusted_velocity)
			adjusted_velocity = given_velocity.rotated(-projectile_spread_increment)
			spawn_new_projectile(get_spawn_origin, adjusted_velocity)
			spawn_loop += 1

##	# for debugging
	else:
		spawn_new_projectile(get_spawn_origin, given_velocity)


func call_spawn_pattern_series():
	pass


func call_spawn_pattern_sniper():
	pass


###############################################################################


func instance_new_projectile(weapon_style):
	var new_projectile = projectile_object.instance()

	# set the values by weapon style here
	# speed of the projectile
	new_projectile.projectile_speed =\
	 current_weapon_style[weapon.DataType.PROJECTILE_FLIGHT_SPEED]
	# size of projectile
	new_projectile.projectile_set_size =\
	 current_weapon_style[weapon.DataType.PROJECTILE_SIZE]

	# projectile lifespan (by timer, before deletion)
	new_projectile.projectile_lifespan =\
	 current_weapon_style[weapon.DataType.PROJECTILE_MAX_LIFESPAN]
	# projectile max lifespan once offscreen (if more than this, set to this)
	new_projectile.offscreen_lifespan =\
	 current_weapon_style[weapon.DataType.PROJECTILE_OFFSCREEN_SPAN]
	# maximum range of projectile from origin
	new_projectile.maximum_range =\
	 current_weapon_style[weapon.DataType.PROJECTILE_MAX_RANGE]
	# maximum number of ticks projectile can be moving before deletion
	new_projectile.maximum_ticks_moving =\
	 current_weapon_style[weapon.DataType.PROJECTILE_MAX_MOVE_TICKS]

	# return the instanced projectile
	return new_projectile


# func for creating a new projectile and setting it on its way
func spawn_new_projectile(spawn_position, spawn_velocity):

	# call the function to instance a new projectile correctly
	# it applies all the related weapon style data dict values to
	# the newly created projectile
	var new_projectile = instance_new_projectile(current_weapon_style)

	new_projectile.position = spawn_position
	new_projectile.velocity = spawn_velocity

	# add projectile to the root viewport for now # TODO replace this
	var projectile_parent = get_tree().get_root()
	projectile_parent.add_child(new_projectile)


###############################################################################


func get_projectile_initial_velocity():
		var firing_velocity = owner.firing_target.normalized()
		return firing_velocity
#	if owner is Actor:
#		var firing_velocity = owner.firing_target
##		return firing_velocity
#	else:
#		# this should not return, WeaponNode is currently actors-only
#		return Vector2(0,0)


# TODO, apply this
func set_projectile_spread():
	# calculated shot rotation
	var shot_randomness = GlobalFuncs.ReturnRandomRange(-shot_spread, shot_spread)
	# shot rotation applied to rotation
	var spread_applied_velocity: Vector2 = shot_velocity.rotated(shot_randomness)


# change projectile rotation_degree using weapon spread float
# apply spawn velocity as position.rotated(by this value)
# rotate proejctile (rotation_degrees) by this value * 10
func return_shot_rotation_from_variance():
	# get variance from weapon style data
	var new_shot_spread = \
	current_weapon_style[weapon.DataType.PROJECTILE_SHOT_VARIANCE]
	# return random value from range (0-variance to 0+variance)
	var rotation_degrees_randomisation = \
	GlobalFuncs.ReturnRandomRange(-new_shot_spread, new_shot_spread)
	return rotation_degrees_randomisation
