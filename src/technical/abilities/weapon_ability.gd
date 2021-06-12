

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
	set_weapon_style(weapon.Style.SNIPER_SHOT)
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
func set_weapon_style(new_weapon_style):
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
	
	# set the current weapon_style
	current_weapon_style = ability_data
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
	projectile_count = current_weapon_style[weapon.DataType.PROJECTILE_COUNT]
#
#	# get the spread pattern rotation applied to velocity
	var projectile_spread_increment = (weapon.SPREAD_PATTERN_WIDTH)
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
	var spread_adjustment
	# TODO rename this variable to be more representative
	# this variable is basically an additive to spawn_loop to get an
	# even distance between projectiles, it varies whether the
	# projectile count is odd or even
	var additional_spread
	
	# TODO account for projecitle size in spread
	
	var projectile_count_even = projectile_count % 2 == 0
	
	if GlobalDebug.projectile_spread_pattern: print("projectile count even = ", projectile_count_even)
	
	# while spawning projectiles  e are going to loop a number of times
	# equal to half the projectiles if even, or half-1 if odd
	var half_projectile_count =\
	projectile_count / 2 if projectile_count_even\
	else (projectile_count - 1) / 2

	# on to the actual spawning of projectiles
	
	# if an odd number of projectiles, spawn a center projectile
	# and set the additional spread to +1
	if not projectile_count_even:
		spawn_new_projectile(get_spawn_origin, given_velocity)
		additional_spread = 1.0
	# else additional spread (for even # of projectiles) is +0.5
	else:
		additional_spread = 0.5
	if GlobalDebug.projectile_spread_pattern: print("additional spread value is ", additional_spread)
	if GlobalDebug.projectile_spread_pattern: print("projectile count is ", projectile_count)
	if GlobalDebug.projectile_spread_pattern: print("data type projectile count is ", current_weapon_style[weapon.DataType.PROJECTILE_COUNT])
	# then we loop to spawn any flanking projectiles
	if projectile_count > 1:
		# limited loop counting variable5
		var spawn_loop = 0
		# bwgin the loop
		if GlobalDebug.projectile_spread_pattern: print("beginning spawn loop!")
		if GlobalDebug.projectile_spread_pattern: print("looping ", half_projectile_count, " times.")
		while spawn_loop < half_projectile_count:
			
			if GlobalDebug.projectile_spread_pattern: print("loop count ", spawn_loop)

			# each loop we will adjust the velocity twice before creating
			# a new projectile with the adjusted velocity
			# the first will positively rotate the spread by the increment total
			# the second will negatively rotate the spread by the increment total
			
			# spread gets wider each loop
			spread_adjustment =\
			projectile_spread_increment * (spawn_loop+additional_spread)
			
			# apply random variance to the fixed spread
			spread_adjustment += return_shot_rotation_from_variance()
			# rotate velocity by spread
			adjusted_velocity = given_velocity.rotated(spread_adjustment)
			# pass owner position for projectile spawn
			# pass the rotated velocity
			# pass the spread adjustment too, utilised for sprite rotation later
			spawn_new_projectile(get_spawn_origin, adjusted_velocity, spread_adjustment)
			
			# repeat the above with negative values
			spread_adjustment += return_shot_rotation_from_variance()
			adjusted_velocity = given_velocity.rotated(-spread_adjustment)
			spawn_new_projectile(get_spawn_origin, adjusted_velocity, -spread_adjustment)
			
			# increment the loop
			spawn_loop += 1


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
func spawn_new_projectile(spawn_position, spawn_velocity, rotation_alteration = 0):

	# call the function to instance a new projectile correctly
	# it applies all the related weapon style data dict values to
	# the newly created projectile
	var new_projectile = instance_new_projectile(current_weapon_style)

	# if spread has been applied, affix a sprite change
	new_projectile.rotation_degrees = rotation_alteration*10

	new_projectile.position = spawn_position
	new_projectile.velocity = spawn_velocity

	# add projectile to the root viewport for now # TODO replace this
	var projectile_parent = get_tree().get_root()
	projectile_parent.add_child(new_projectile)


###############################################################################


func get_projectile_initial_velocity():
	if owner is Actor:
		var firing_velocity = owner.firing_target.normalized()
		return firing_velocity
	else:
		# this should not return, WeaponNode is currently actors-only
		return Vector2(0,0)


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


###############################################################################
###############################################################################
#
# DEFUNCT FUNCTIONS BELOW HERE
#
## defunct, remove later
#func defunct_testing_of_call_spawn_pattern_spread():
#	# TODO implement handling for 
#	# use our current weapon style to get the number of projectiles fired
#	var get_projectile_count = \
#	current_weapon_style[weapon.DataType.PROJECTILE_COUNT]
##
##	# get the rotation applied to velocity for spread shots
#	var base_projectile_spread = weapon.SPREAD_PATTERN_WIDTH
#
#	var projectile_spread_increment = (weapon.SPREAD_PATTERN_WIDTH * 0.75)
###
##	# get our position for spawn origin
#	var get_spawn_origin = owner.position
#	# initial velocity determined by the actor
#	# specifically by the actor's 'firing_target'
#	# for a player it is a vector toward their mouse position
#	# (at the time they pressed the fire key)
#	# for any AI it is the actor or entity they are aiming at
#	# (after introducing some fake 'poor aim' and/or 'aiming delay')
#	var given_velocity = get_projectile_initial_velocity()
#	# adjusted velocity is the velocity accounting for projectile spread
#	var adjusted_velocity
#	# this is to store the total rotation applied to projectile velocity
#	var total_spread_increment_counter
#
#	spawn_new_projectile(get_spawn_origin, given_velocity)
