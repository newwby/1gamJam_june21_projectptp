
class_name State_Attack, "res://art/shrek_pup_eye_sprite.png"
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


#	elif current_target != null and check_if_weapon_can_fire()\
#	 and current_state != State.ATTACK:
#		set_new_state(State.ATTACK)


# ATTACK STATE
# get the target, create target line, delay according to reaction, fire, 
func state_attack_activate_weapon():
	var weapon_target = acquire_weapon_target()
				# Prep to fire at that target
					# Anticipate/pause
					# Create target line
					# Timer delay before firing
					# Fire shot/trigger weapon
					# Recover/pause
					# Set attack cooldown timer
					# GOTO CHECK STATE


func acquire_weapon_target():
	pass
	# Figure out who is closest enemy
