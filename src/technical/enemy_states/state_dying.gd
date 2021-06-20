
class_name State_Dying, "res://art/shrek_pup_eye_sprite.png"
extends State


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# DYING STATE
# stop everything else, end the enemy
func state_dying_enemy_begins_to_die():
	handle_enemy_dying()


# actual function for dying state
func handle_enemy_dying():
	pass
