extends Node

# move to global variables, predates global var
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

###############################################################################

# paths to various resources handled by multiple scenes
# the default weapon projectile modified by weapon style data
const default_projectile = "res://src/entities/projectile.tscn"
# node that handles deletion of node2d instances created by orbital
# projectile spawn pattern (now defunct, handled elsewhere)
const node_2d_deletion = "res://src/technical/node2d_deletion_handler.gd"
# technical modifiers
# technical modifier for time slow ability
const modifier_time_slow = "res://src/technical/modifiers/modifier_time_slow.tscn"
# graphical effects
# particle that travels across the screen at a rotating offset
const windy_leaf_particle = "res://src/effect/level_windy_leaf_particle.tscn"

###############################################################################

# paths to sprite graphics for collectables
const sprite_weapon_split_shot = "res://art/icons/lorc-gameicons_striking_arrows.png"
const sprite_weapon_triple_burst_shot = "res://art/icons/lorc-gameicons_bullets.png"
const sprite_weapon_sniper_shot = "res://art/icons/lorc-gameicons_sniper.png"
const sprite_weapon_rapid_shot = "res://art/icons/lorc-gameicons_missile_swarm.png"
const sprite_weapon_heavy_shot = "res://art/icons/lorc-gameicons_comet_spark.png"
const sprite_weapon_vortex_shot = "res://art/icons/lorc-gameicons_orbital.png"

#TODO add weapon collectable and projectile graphics to weapon style data
# paths to projectile graphics
const sprite_projectile_split_shot = "res://art/projectile/kenney_simplespace/meteor_squareLarge.png"
const sprite_projectile_triple_burst_shot = "res://art/projectile/kenney_simplespace/meteor_squareDetailedLarge.png"
const sprite_projectile_sniper_shot = "res://art/projectile/kenney_simplespace/station_B.png"
const sprite_projectile_rapid_shot = "res://art/projectile/kenney_simplespace/star_tiny.png"
const sprite_projectile_heavy_shot = "res://art/projectile/kenney_simplespace/meteor_detailedLarge.png"
const sprite_projectile_vortex_shot = "res://art/projectile/kenney_simplespace/meteor_large.png"
const sprite_projectile_smoke = "res://art/projectile/kenney_smokeparticleassets/PNG/Black smoke/blackSmoke00.png"
const sprite_projectile_fire_cloud = "res://art/projectile/kenney_particlePack_1.1/flame_02.png"
const sprite_projectile_scythe = "res://art/kenney_particle1.1/twirl_01.png"
const sprite_projectile_bolt_lance = "res://art/projectile/kenney_particlePack_1.1/trace_05.png"

###############################################################################

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

const DESC_NONE =\
"Invalid description string"

###############################################################################
