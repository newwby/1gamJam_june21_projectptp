extends Node

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
