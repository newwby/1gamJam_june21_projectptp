extends Node2D

var waves_to_spawn

onready var wave_handler_container = $WaveHandlers
onready var wave_trigger = $WaveTriggerArea


##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_waves_to_spawn()


###############################################################################


func set_waves_to_spawn():
	waves_to_spawn = wave_handler_container.get_children()


###############################################################################


func _on_WaveTriggerArea_body_entered(body):
	if GlobalDebug.wave_spawn_handling_logs: print(body.name, " has entered trigger zone")
	wave_trigger.set_deferred("monitoring", false)
	wave_trigger.set_deferred("monitorable", false)
	begin_wave_spawning(body)


func begin_wave_spawning(body):
	if GlobalDebug.wave_spawn_handling_logs: print("begin spawning process")
	for wave in waves_to_spawn:
		if GlobalDebug.wave_spawn_handling_logs: print("loop at spawn ", wave.name, ", a new wave.")	
		if wave is WaveSpawner:
			if GlobalDebug.wave_spawn_handling_logs: print("calling spawn_wave_enemies on ", wave.name)
			wave.spawn_wave_enemies(body)
			yield(wave, "wave_complete")
