extends Node

# paths to various resources handled by multiple scenes
const default_projectile = "res://src/entities/projectile.tscn"

# paths to sprite graphics for collectables
const sprite_weapon_split_shot = "res://art/icons/lorc-gameicons_striking_arrows.png"
const sprite_weapon_triple_burst_shot = "res://art/icons/lorc-gameicons_bullets.png"
const sprite_weapon_sniper_shot = "res://art/icons/lorc-gameicons_sniper.png"
const sprite_weapon_rapid_shot = "res://art/icons/lorc-gameicons_missile_swarm.png"
const sprite_weapon_heavy_shot = "res://art/icons/lorc-gameicons_comet_spark.png"
const sprite_weapon_vortex_shot = "res://art/icons/lorc-gameicons_orbital.png"

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
"Fires shots that stop and orbit the attacker"

# enum for various collision layers, for standardised setting in code
enum CollisionLayers {
	PLAYER_BODY,
	PLAYER_ENTITY,
	ENEMY_BODY,
	ENEMY_ENTITY,
	OBSTACLE,
	GROUND_EFFECT,
	ROOM_WALL,
	COLLECTABLE,
}
