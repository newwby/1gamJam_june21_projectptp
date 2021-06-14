extends Node2D

var expiry_time = 10.0

onready var modifier_expiry_timer = $ExpiryTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	modifier_expiry_timer.wait_time = expiry_time
	modifier_expiry_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
