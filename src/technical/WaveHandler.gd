extends Node2D

enum SpawnableEnemy {NONE, BASIC_GREEN_SNAKE, ELITE_RED_SNAKE, CROC_SNIPER, \
CREEP_GIRAFFE, WOLVERINE_TANK, WIND_SCYTHER}

export(SpawnableEnemy) var enemy_to_spawn_in_1
export(SpawnableEnemy) var enemy_to_spawn_in_2
export(SpawnableEnemy) var enemy_to_spawn_in_3
export(SpawnableEnemy) var enemy_to_spawn_in_4
export(SpawnableEnemy) var enemy_to_spawn_in_5
export(SpawnableEnemy) var enemy_to_spawn_in_6
export(SpawnableEnemy) var enemy_to_spawn_in_7
export(SpawnableEnemy) var enemy_to_spawn_in_8
export(SpawnableEnemy) var enemy_to_spawn_in_9
export(SpawnableEnemy) var enemy_to_spawn_in_10

var list_of_enemies_to_spawn = [
	enemy_to_spawn_in_1,
	enemy_to_spawn_in_2,
	enemy_to_spawn_in_3,
	enemy_to_spawn_in_4,
	enemy_to_spawn_in_5,
	enemy_to_spawn_in_6,
	enemy_to_spawn_in_7,
	enemy_to_spawn_in_8,
	enemy_to_spawn_in_9,
	enemy_to_spawn_in_10,
]
