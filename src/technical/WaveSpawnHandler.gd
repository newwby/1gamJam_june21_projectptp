extends Node2D

# total number of spawn positions to use, between 1 and 6
export(int, 1, 6) var total_spawn_positions = 6
# total number of waves to spawn, between 1 and 4
export(int, 1, 4) var total_waves = 4
# length of time in seconds before next wave begins
export(int, 1, 60, 1) var wave_max_length = 30
# length of time in seconds(/ms) between enemy spawns
# also controls length of time spawn particles will emit for
export(float, 0, 1, 0.1) var enemy_spawn_delay = 0.2

onready var wave_length_timer = $WaveMaxLength
onready var spawn_delay_timer = $WaveBetweenSpawnDelay
onready var wave_trigger = $WaveTriggerArea


# Called when the node enters the scene tree for the first time.
func _ready():
	set_timer_parameters()


func set_timer_parameters():
	wave_length_timer.wait_time = wave_max_length
	spawn_delay_timer.wait_time = enemy_spawn_delay


func _on_WaveTriggerArea_body_entered(body):
	wave_trigger.monitoring = false
	wave_trigger.monitorable = false


func begin_wave_spawning():
	pass


func spawn_next_wave(wave_contents):
	pass
