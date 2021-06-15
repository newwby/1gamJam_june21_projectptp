
extends File

# the increment of projectile spread per pair of shots fired
# in the spread projectile spawning pattern
const SPREAD_PATTERN_WIDTH: float = 0.1

# the distance between orbital spawn pattern
const ORBIT_PATTERN_ROTATION_SPACING: int = 45

# weapon style controls the style data a weapon ability uses
enum Style {
	# player and enemy
	SPLIT_SHOT,
	TRIPLE_BURST_SHOT,
	SNIPER_SHOT,
	RAPID_SHOT,
	HEAVY_SHOT,
	VORTEX_SHOT,
	# enemy only
	RADAR_SWEEP_SHOT,
	BASIC_SHOT,
}

# spawn pattern determines where projectiles are spawned in an attack
# relevant to the spawner. projectiles may spawn in different places
# as more are added
enum SpawnPattern {
	SPREAD, # additional projectiles fire from sides, widening spread
	SERIES, # additional projectiles fire from same point as first
	O, # spawn pattern does not matter, just spawn
}


# aim type determines how the weapon interprets player aiming
enum AimType {
	FREE_AIM, # fire toward current mouse position
	SNIPER_AIM, # fire toward current sprite_rotation
	FIXED_ON_HOLD, # fire toward mouse position at time of holding fire button
}


# projectile sprite is the animation to use for top and bottom layer
enum ProjectileSprite {
	MAGICAL,
}

# projectile sprite is the particle effect applied to the projectile
enum ProjectileParticles {
	NONE,
}

# spawn surge effect is an effect that plays when the shot is fired
enum SpawnSurgeEffect {
	NONE,
}

# when are sound effects played
enum AudioStyle {
	WHILST_HELD,
	ON_PRIMED,
	ON_FIRE,
}

# sound effect played when the weapon/shot is fired
enum ShotSound {
	NONE,
	SPLIT_SHOT,
}

# data types is a list of every parameter determined by the
# weapon style data dictionary
enum DataType {
	NAME,
	DESCRIPTION_STRINGREF,
	WEAPON_ICON_SPRITE,
	PROJECTILE_SPRITE_TYPE,
	PROJECTILE_SPRITE_COLOUR,
	PROJECTILE_SPRITE_ROTATE,
	PROJECTILE_PARTICLES,
	SHOT_AUDIO_STYLE,
	SHOT_SOUND_EFFECT,
	SHOT_SURGE_EFFECT,
	SHOT_AIM_TYPE,
	SHOT_USE_COOLDOWN,
	SHOT_STATIONARY_BONUS,
	AI_MIN_USE_RANGE,
	AI_MAX_USE_RANGE,
	BASE_DAMAGE,
	PROJECTILE_SIZE,
	PROJECTILE_MAX_MOVE_TICKS,
	PROJECTILE_MAX_RANGE,
	PROJECTILE_MAX_LIFESPAN,
	PROJECTILE_OFFSCREEN_SPAN,
	PROJECTILE_MOVE_PATTERN,
	PROJECTILE_SPAWN_PATTERN,
	PROJECTILE_SPAWN_DELAY,
	USE_SNIPER_AIM_LINE,
	PROJECTILE_COUNT,
	PROJECTILE_FLIGHT_SPEED,
	PROJECTILE_SPEED_INHERIT,
	PROJECTILE_SHOT_VARIANCE,
}

# TODO
# Add data types for

#	ref		TriggerSecondaryWeapon	# or reference to another weapon?
#	enum	TriggerCondition		# on hit, on crit, on timer
#	array	onHitEffects			# an array containing everything checked on hit, status, triggers etc
#	bool	TriggerSignal			# or reference to signal?
#	bool	TriggerStatusEffect		# or status effect class
#	bool	TriggerStackOnHit		# or stack class
#	bool	TriggerAoE				# or AoE class

#	Float	BaseCriticalChance
#	Float	BaseCriticalMultiplier	

#	enum	AoEShape {LINE, WAVE, CONE, NOVA}
#	enum	AoESpawnType {AT_ATTACKER, AT_TARGET}
#	float	AoE Size
#	int		AoE Damage
#	int		AoE Instances
#	int		AoE Spacing
#	bool	isAoEEchoing

#	bool	isProjectileContactDamage

# replace flightspeed w/
#	float	ProjectileBaseSpeed
#	float	ProjectileAcceleration	# (acceleration rate per tick?)
#	float	ProjectileTopSpeed

#	bool	isProjectileSeeking
#	float	ProjectileSteering

#	float	FixedSpreadWidth		# projectiles can go full circle atm

#	bool	isFixedFiringTarget		# can the player aim freely whilst firing?
#	bool	isRootedDuringShot		# can the player move whilst firing?

# TODO
# implement enum/array for on-contact actions
# e.g. status effects and triggering other abilities
#
# implement velocity inheritance multiplier on weapon type
# (const INHERITED_VELOCITY_MULTIPLIER)

###############################################################################

# weapon style data includes all the information
# relevant to how a weapon ability functions in game
const STYLE_DATA = {
	
	Style.SPLIT_SHOT : {
		DataType.NAME						: "Split Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_SPLIT_SHOT,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_split_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_split_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.aliceblue,
		DataType.PROJECTILE_SPRITE_ROTATE	: 12,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.ON_FIRE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FREE_AIM,
		DataType.SHOT_USE_COOLDOWN			: 0.5,
		DataType.SHOT_STATIONARY_BONUS		: 0.85,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 8,
		DataType.PROJECTILE_SIZE			: 0.8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 3,
		DataType.PROJECTILE_FLIGHT_SPEED	: 600,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.4,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.01,
	
	},
	
	Style.TRIPLE_BURST_SHOT : {
		"Name"								 : "Triple Burst Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_TRIPLE_BURST_SHOT,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_triple_burst_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_triple_burst_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.silver,
		DataType.PROJECTILE_SPRITE_ROTATE	: 16,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.ON_FIRE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FREE_AIM,
		DataType.SHOT_USE_COOLDOWN			: 1.2,
		DataType.SHOT_STATIONARY_BONUS		: 0.75,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 15,
		DataType.PROJECTILE_SIZE			: 1.0,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SERIES,
		DataType.PROJECTILE_SPAWN_DELAY		: 0.075,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 3,
		DataType.PROJECTILE_FLIGHT_SPEED	: 1300,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.6,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.15,
	},
	
	Style.SNIPER_SHOT : {
		"Name" 								: "Sniper Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_SNIPER_SHOT,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_sniper_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_sniper_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.forestgreen,
		DataType.PROJECTILE_SPRITE_ROTATE	: 32,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.ON_FIRE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.SNIPER_AIM,
		DataType.SHOT_USE_COOLDOWN			: 1.4,
		DataType.SHOT_STATIONARY_BONUS		: 0.5,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.DISTANT,
		DataType.BASE_DAMAGE				: 35,
		DataType.PROJECTILE_SIZE			: 1.2,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 10000,
		DataType.PROJECTILE_MAX_RANGE		: 800,
		DataType.PROJECTILE_MAX_LIFESPAN	: 8.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 4.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SERIES,
		DataType.PROJECTILE_SPAWN_DELAY		: 1.6,
		DataType.USE_SNIPER_AIM_LINE		: true,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 2400,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.4,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.01,
	},
	
	Style.RAPID_SHOT : {
		"Name" 								: "Rapid Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_RAPID_SHOT,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_rapid_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_rapid_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.fuchsia,
		DataType.PROJECTILE_SPRITE_ROTATE	: 18,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.WHILST_HELD,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FREE_AIM,
		DataType.SHOT_USE_COOLDOWN			: 0.12,
		DataType.SHOT_STATIONARY_BONUS		: 0.75,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 4,
		DataType.PROJECTILE_SIZE			: 0.8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 1000,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.6,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.15,
	},
	
	Style.HEAVY_SHOT : {
		"Name" 								: "Heavy Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_HEAVY_SHOT,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_heavy_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_heavy_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.firebrick,
		DataType.PROJECTILE_SPRITE_ROTATE	: 4,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.ON_FIRE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FREE_AIM,
		DataType.SHOT_USE_COOLDOWN			: 1.0,
		DataType.SHOT_STATIONARY_BONUS		: 0.85,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.MELEE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.BASE_DAMAGE				: 40,
		DataType.PROJECTILE_SIZE			: 2.5,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 400,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.2,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.05,
	},
	
	Style.VORTEX_SHOT : {
		"Name" 								: "Vortex Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_VORTEX_SHOT,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_vortex_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_vortex_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.orangered,
		DataType.PROJECTILE_SPRITE_ROTATE	: 12,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.WHILST_HELD,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FIXED_ON_HOLD,
		DataType.SHOT_USE_COOLDOWN			: 0.35,
		DataType.SHOT_STATIONARY_BONUS		: 0.95,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.MELEE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.BASE_DAMAGE				: 20,
		DataType.PROJECTILE_SIZE			: 0.8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 8000,
		DataType.PROJECTILE_MAX_RANGE		: 400,
		DataType.PROJECTILE_MAX_LIFESPAN	: 2.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.75,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.ORBIT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 300,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.0,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.05,
	},
	
	# below this point
	# the projectile styles included
	# are not for the player
	# they are for enemies and bosses
	# or turrets
	# only
	# staggered this comment to make
	# it obvious when I'm scrolling
	# through quickly
	# that there's some kind of difference
	# beyond this point
	
	Style.RADAR_SWEEP_SHOT : {
		"Name" 								: "Radar Sweep Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_NONE,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_weapon_vortex_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_vortex_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.bisque,
		DataType.PROJECTILE_SPRITE_ROTATE	: 12,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.WHILST_HELD,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FIXED_ON_HOLD,
		DataType.SHOT_USE_COOLDOWN			: 0.5,
		DataType.SHOT_STATIONARY_BONUS		: 0.95,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.MELEE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.BASE_DAMAGE				: 10,
		DataType.PROJECTILE_SIZE			: 0.8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 8000,
		DataType.PROJECTILE_MAX_RANGE		: 400,
		DataType.PROJECTILE_MAX_LIFESPAN	: 2.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.RADAR,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 100,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.0,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.05,
	},
	
	Style.BASIC_SHOT : {
		"Name" 								: "Basic Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_NONE,
		DataType.WEAPON_ICON_SPRITE			: GlobalReferences.sprite_projectile_split_shot,
		DataType.PROJECTILE_SPRITE_TYPE		: GlobalReferences.sprite_projectile_split_shot,
		DataType.PROJECTILE_SPRITE_COLOUR	: Color.red,
		DataType.PROJECTILE_SPRITE_ROTATE	: 6,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_AUDIO_STYLE			: AudioStyle.WHILST_HELD,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_AIM_TYPE				: AimType.FIXED_ON_HOLD,
		DataType.SHOT_USE_COOLDOWN			: 0.75,
		DataType.SHOT_STATIONARY_BONUS		: 0.95,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 12,
		DataType.PROJECTILE_SIZE			: 1.0,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 8000,
		DataType.PROJECTILE_MAX_RANGE		: 400,
		DataType.PROJECTILE_MAX_LIFESPAN	: 5.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 2.0,
		DataType.PROJECTILE_MOVE_PATTERN	: GlobalVariables.ProjectileMovement.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.USE_SNIPER_AIM_LINE		: false,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 150,
		DataType.PROJECTILE_SPEED_INHERIT	: 0.0,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.05,
	},
}
