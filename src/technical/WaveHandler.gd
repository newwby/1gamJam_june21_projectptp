
class_name WaveSpawner
extends Node2D

signal wave_complete

enum SpawnableEnemy {NONE, BASIC_GREEN_SNAKE, ELITE_RED_SNAKE, CROC_SNIPER, \
CREEP_GIRAFFE, WOLVERINE_TANK, WIND_SCYTHER}

# total number of spawn positions to use, between 1 and 6
export(int, 1, 6) var total_spawn_positions = 6
# length of time in seconds before next wave begins
export(int, 1, 60, 1) var wave_max_length = 30
# length of time in seconds(/ms) between enemy spawns
# also controls length of time spawn particles will emit for
export(float, 0, 2, 0.1) var enemy_spawn_delay = 0.4
# control particle spawn size
export(float, 0.025, 1, 0.025)  var particle_scale_amount = 0.25

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

var is_wave_active = false
var is_wave_completed = false

var current_spawn_position = 0

var total_number_of_enemies_to_spawn = 0
var total_enemies_defeated = 0

var list_of_enemies_to_spawn

onready var wave_spawn_pos_1 = $EnemySpawnLocations/WaveSpawnPosition1
onready var wave_spawn_pos_2 = $EnemySpawnLocations/WaveSpawnPosition2
onready var wave_spawn_pos_3 = $EnemySpawnLocations/WaveSpawnPosition3
onready var wave_spawn_pos_4 = $EnemySpawnLocations/WaveSpawnPosition4
onready var wave_spawn_pos_5 = $EnemySpawnLocations/WaveSpawnPosition5
onready var wave_spawn_pos_6 = $EnemySpawnLocations/WaveSpawnPosition6

onready var enemy_holder_node = $EnemyHolder

onready var enemy_type_basic_green_snake = load(GlobalReferences.enemy_basic_snake)
onready var enemy_type_elite_red_snake = load(GlobalReferences.enemy_elite_snake)
onready var enemy_type_crocodile_sniper = load(GlobalReferences.enemy_croc_sniper)
onready var enemy_type_giraffe_creeper = load(GlobalReferences.enemy_creep_giraffe)
onready var enemy_type_wolverine_tank = load(GlobalReferences.enemy_wolverine_tank)
onready var enemy_type_wind_scyther = load(GlobalReferences.enemy_wind_scyther)

onready var wave_length_timer = $WaveMaxLength
onready var spawn_delay_timer = $WaveBetweenSpawnDelay


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_timer_parameters()
	set_list_of_enemies_to_spawn()
	set_total_spawns()


###############################################################################


# need to configure timers for later, according to the exportable values
func set_timer_parameters():
	wave_length_timer.wait_time = wave_max_length
	spawn_delay_timer.wait_time = enemy_spawn_delay


# need to know how many enemies there are to spawn
func set_total_spawns():
	for enemy in list_of_enemies_to_spawn:
		if enemy != SpawnableEnemy.NONE:
			total_number_of_enemies_to_spawn += 1


# has to be set after ready
func set_list_of_enemies_to_spawn():
	list_of_enemies_to_spawn = [
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


###############################################################################


# usage - loop this function on a wave handler's list_of_enemies_to_spawn
func get_enemy_instance(enemy_type):
	# match the given wave's spawnable enemies
	match enemy_type:
		SpawnableEnemy.BASIC_GREEN_SNAKE:
			return enemy_type_basic_green_snake.instance()
		SpawnableEnemy.ELITE_RED_SNAKE:
			return enemy_type_elite_red_snake.instance()
		SpawnableEnemy.CROC_SNIPER:
			return enemy_type_crocodile_sniper.instance()
		SpawnableEnemy.CREEP_GIRAFFE:
			return enemy_type_giraffe_creeper.instance()
		SpawnableEnemy.WOLVERINE_TANK:
			return enemy_type_wolverine_tank.instance()
		SpawnableEnemy.WIND_SCYTHER:
			return enemy_type_wind_scyther.instance()
		SpawnableEnemy.NONE:
			return null


###############################################################################

func spawn_wave_enemies(target_to_attack):
	if GlobalDebug.wave_spawn_handling_logs: print("starting spawn_wave_enemies on ", self.name)
	
	is_wave_active = true
	
	# begin timer to count whether wave has gone on too long
	wave_length_timer.start()
	
	var next_spawn_position
	
	# loop through list, one item at a time separated by wave spawn delay
	if GlobalDebug.wave_spawn_handling_logs: print("looping through list_of_enemies_to_spawn")
	if GlobalDebug.wave_spawn_handling_logs: print("list_of_enemies_to_spawn contains:")
	if GlobalDebug.wave_spawn_handling_logs: print(list_of_enemies_to_spawn)
	for enemy_to_spawn in list_of_enemies_to_spawn:
		
		# get new enemy instance to spawn and check is valid
		var new_spawn_instance = get_enemy_instance(enemy_to_spawn)
		# if enemy is null we skip to next loop
		if new_spawn_instance != null and new_spawn_instance is Enemy:
			# disable and hide
			new_spawn_instance.visible = false
			new_spawn_instance.is_active = false
			# set position for spawn
			next_spawn_position = get_next_spawn_position()
			# if spawn position is invalid for some reason we skip to next loop
			if next_spawn_position != null:
				new_spawn_instance.global_position = next_spawn_position.global_position
			
				# begin the spawn procedure
				# get node path to particles then begin particle emit/spawn
				var particle_path = str(next_spawn_position.get_path()) + "/SpawnParticles"
				get_node(particle_path).scale_amount = particle_scale_amount
				get_node(particle_path).emitting = true
				# start wave delay timer and delay until wave delay timer elapses
				spawn_delay_timer.start()
				yield(spawn_delay_timer, "timeout")
				# stop particles
				get_node(particle_path).emitting = false
				# add and enable new enemy instance
				# connect signal
				new_spawn_instance.connect("enemy_defeated", self, "_on_EnemyDefeated")
				# add to scene root and set aggressive
				new_spawn_instance.visible = true
				new_spawn_instance.is_active = true
				get_tree().get_root().add_child(new_spawn_instance)
				new_spawn_instance._on_Enemy_damaged(0, target_to_attack)
	
	# on finishing the list loop
	if is_wave_active:
		emit_signal("wave_complete")


# cycle through the spawn position nodes in order
func get_next_spawn_position():
	current_spawn_position += 1
	if current_spawn_position > 6 or\
	current_spawn_position > total_spawn_positions or\
	current_spawn_position < 1:
		current_spawn_position = 1
	
	match current_spawn_position:
		1:
			return wave_spawn_pos_1
		2:
			return wave_spawn_pos_2
		3:
			return wave_spawn_pos_3
		4:
			return wave_spawn_pos_4
		5:
			return wave_spawn_pos_5
		6:
			return wave_spawn_pos_6


func _on_EnemyDefeated():
	total_enemies_defeated += 1
	if total_enemies_defeated >= total_number_of_enemies_to_spawn\
	and is_wave_active:
		emit_signal("wave_complete")


# handles if wave goes on too long to call next wave
func _on_WaveMaxLength_timeout():
	if is_wave_active:
		emit_signal("wave_complete")


# handles when wave calls the next wave
func _on_SpawnWave1_wave_complete():
	is_wave_active = false
	is_wave_completed = true
	if not wave_length_timer.is_stopped():
		wave_length_timer.stop()
