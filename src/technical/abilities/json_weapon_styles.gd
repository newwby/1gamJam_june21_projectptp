
extends File

# constant are utilised for the 'spread' spawn pattern
const SPREAD_PATTERN_WIDTH: float = 0.05

# weapon style controls the style data a weapon ability uses
enum Style {
	SPLIT_SHOT,
	TRIPLE_BURST_SHOT,
	SNIPER_SHOT,
	RAPID_SHOT,
	HEAVY_SHOT,
	VORTEX_SHOT,
}

# movement behaviour determines how the projectile behaves once spawned
enum MovementBehaviour {
	DIRECT,
	ORBIT,
}

# spawn pattern determines where projectiles are spawned in an attack
# relevant to the spawner. projectiles may spawn in different places
# as more are added
enum SpawnPattern {
	SPREAD, # additional projectiles fire from sides, widening spread
	SERIES, # additional projectiles fire from same point as first
	SNIPER, # during shot spawn delay spawns a line
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
	PROJECTILE_SPRITE_TYPE,
	PROJECTILE_SPRITE_ROTATE,
	PROJECTILE_PARTICLES,
	SHOT_SOUND_EFFECT,
	SHOT_SURGE_EFFECT,
	SHOT_USE_COOLDOWN,
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
	PROJECTILE_COUNT,
	PROJECTILE_FLIGHT_SPEED,
	PROJECTILE_SHOT_VARIANCE,
}


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
		DataType.PROJECTILE_SPRITE_TYPE		: ProjectileSprite.MAGICAL,
		DataType.PROJECTILE_SPRITE_ROTATE	: 0,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_USE_COOLDOWN			: 0.5,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 12,
		DataType.PROJECTILE_SIZE			: 8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0,
		DataType.PROJECTILE_COUNT			: 2,#3,
		DataType.PROJECTILE_FLIGHT_SPEED	: 750,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.01,
	
	},
	
	Style.TRIPLE_BURST_SHOT : {
		"Name"								 : "Triple Burst Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_TRIPLE_BURST_SHOT,
		DataType.PROJECTILE_SPRITE_TYPE		: ProjectileSprite.MAGICAL,
		DataType.PROJECTILE_SPRITE_ROTATE	: 0,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_USE_COOLDOWN			: 1.2,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 10,
		DataType.PROJECTILE_SIZE			: 8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY		: 0.4,
		DataType.PROJECTILE_COUNT			: 3,
		DataType.PROJECTILE_FLIGHT_SPEED	: 800,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.15,
	},
	
	Style.SNIPER_SHOT : {
		"Name" 								: "Sniper Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_SNIPER_SHOT,
		DataType.PROJECTILE_SPRITE_TYPE		: ProjectileSprite.MAGICAL,
		DataType.PROJECTILE_SPRITE_ROTATE	: 0,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_USE_COOLDOWN			: 1.6,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.DISTANT,
		DataType.BASE_DAMAGE				: 25,
		DataType.PROJECTILE_SIZE			: 14,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 10000,
		DataType.PROJECTILE_MAX_RANGE		: 800,
		DataType.PROJECTILE_MAX_LIFESPAN	: 8.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 4.0,
		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SNIPER,
		DataType.PROJECTILE_SPAWN_DELAY	: 0,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 1600,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.01,
	},
	
	Style.RAPID_SHOT : {
		"Name" 								: "Rapid Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_RAPID_SHOT,
		DataType.PROJECTILE_SPRITE_TYPE		: ProjectileSprite.MAGICAL,
		DataType.PROJECTILE_SPRITE_ROTATE	: 0,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_USE_COOLDOWN			: 0.2,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.CLOSE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.FAR,
		DataType.BASE_DAMAGE				: 4,
		DataType.PROJECTILE_SIZE			: 6,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY	: 0,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 1000,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.15,
	},
	
	Style.HEAVY_SHOT : {
		"Name" 								: "Heavy Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_HEAVY_SHOT,
		DataType.PROJECTILE_SPRITE_TYPE		: ProjectileSprite.MAGICAL,
		DataType.PROJECTILE_SPRITE_ROTATE	: 15,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_USE_COOLDOWN			: 1.0,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.MELEE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.BASE_DAMAGE				: 40,
		DataType.PROJECTILE_SIZE			: 24,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 6000,
		DataType.PROJECTILE_MAX_RANGE		: 600,
		DataType.PROJECTILE_MAX_LIFESPAN	: 4.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.DIRECT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY	: 0,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 400,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.05,
	},
	
	Style.VORTEX_SHOT : {
		"Name" 								: "Vortex Shot",
		DataType.DESCRIPTION_STRINGREF		: GlobalReferences.DESC_VORTEX_SHOT,
		DataType.PROJECTILE_SPRITE_TYPE		: ProjectileSprite.MAGICAL,
		DataType.PROJECTILE_SPRITE_ROTATE	: 0,
		DataType.PROJECTILE_PARTICLES		: ProjectileParticles.NONE,
		DataType.SHOT_SOUND_EFFECT			: ShotSound.NONE,
		DataType.SHOT_SURGE_EFFECT			: SpawnSurgeEffect.NONE,
		DataType.SHOT_USE_COOLDOWN			: 0.6,
		DataType.AI_MIN_USE_RANGE			: GlobalVariables.RangeGroup.MELEE,
		DataType.AI_MAX_USE_RANGE			: GlobalVariables.RangeGroup.NEAR,
		DataType.BASE_DAMAGE				: 10,
		DataType.PROJECTILE_SIZE			: 8,
		DataType.PROJECTILE_MAX_MOVE_TICKS	: 8000,
		DataType.PROJECTILE_MAX_RANGE		: 400,
		DataType.PROJECTILE_MAX_LIFESPAN	: 6.0,
		DataType.PROJECTILE_OFFSCREEN_SPAN	: 1.0,
		DataType.PROJECTILE_MOVE_PATTERN	: MovementBehaviour.ORBIT,
		DataType.PROJECTILE_SPAWN_PATTERN	: SpawnPattern.SPREAD,
		DataType.PROJECTILE_SPAWN_DELAY	: 0,
		DataType.PROJECTILE_COUNT			: 1,
		DataType.PROJECTILE_FLIGHT_SPEED	: 500,
		DataType.PROJECTILE_SHOT_VARIANCE	: 0.05,
	},
}