extends Node

# paths to various resources handled by multiple scenes
const default_projectile = "res://src/entities/projectile.tscn"

# string references for descriptions
# descriptions for weapon types
const DESC_SPLIT_SHOT =\
"Fires 3 projectiles in a split pattern."
const DESC_TRIPLE_BURST_SHOT =\
"Fires 3 projectiles in a series pattern."
const DESC_SNIPER_SHOT =\
"Fires a single high speed powerful projectile."
const DESC_RAPID_SHOT =\
"Fires single projectiles as rapidly as possible."
const DESC_HEAVY_SHOT =\
"Fires a large slow shot that deals high damage."
const DESC_VORTEX_SHOT =\
""

enum CollisionLayers {
	PLAYER_BODY,
	PLAYER_PROJECTILE,
	ENEMY_BODY,
	ENEMY_PROJECTILE,
	OBSTACLE,
	GROUND_EFFECT,
	ROOM_WALL,
}
