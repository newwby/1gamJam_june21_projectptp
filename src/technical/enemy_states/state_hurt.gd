
class_name State_Hurt, "res://art/shrek_pup_eye_sprite.png"
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


###############################################################################


	# If hurt, change state and append state register
		# Check if dead
			# Stop all other processing
			# Process dead
		# If not dead
			# Process hurt
			# Check state



# HURT STATE
# interrupts behaviour and starts damaged/aggression timer
func state_hurt_enemy_is_damaged():
	handle_enemy_taking_damage()


# actual function for hurt state
func handle_enemy_taking_damage():
	pass
