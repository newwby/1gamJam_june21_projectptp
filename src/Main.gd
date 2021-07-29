extends Node2D

export var is_quickload = true

onready var game_environment = $GameEnvironment

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_quickload:
		game_environment.starting_game_splash_fade_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
