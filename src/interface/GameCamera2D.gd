extends Camera2D

var camera_target


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera_target != null:
		self.position = camera_target.position
