
class_name enemy
extends Actor

# TODO sort out enemy auto scaling


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("enemies")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
