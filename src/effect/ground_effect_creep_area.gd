extends Area2D

export var creep_damage = 20
export var creep_timer_duration = 3.0
export var creep_particle_duration = 2.0

var creep_owner

onready var creep_expiry_timer = $FadeTimer
onready var particle_anim = $CreepParticles

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	creep_expiry_timer.wait_time = creep_timer_duration
	particle_anim.lifetime = creep_particle_duration
	particle_anim.emitting = true
	creep_expiry_timer.start()


###############################################################################


func _on_FadeTimer_timeout():
	delete_self()


func _on_CreepZone_body_entered(body):
	if body is Player:
		body.emit_signal("damaged", creep_damage, creep_owner)
		delete_self()


###############################################################################


func delete_self():
	call_deferred("queue_free")
