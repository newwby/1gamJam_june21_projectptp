extends Node

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

enum RangeGroup {
	MELEE,
	CLOSE,
	NEAR,
	FAR,
	DISTANT,
}

# movement behaviour determines how a projectile behaves once spawned
enum ProjectileMovement {
	DIRECT,
	ORBIT,
	RADAR,
}


# active abilities for players
enum AbilityTypes {
	BLINK,
	TIME_SLOW,
}
