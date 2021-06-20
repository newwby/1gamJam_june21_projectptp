
class_name State_Searching, "res://art/shrek_pup_eye_sprite.png"
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


#	elif current_target == null\
#	 and target_last_known_location != null\
#	 and current_state != State.SEARCH:
#		set_new_state(State.SEARCH)

	
	# If can't see nearby target, did we lose track of a target?
		# Check far group, if we find a target
			# Store target position and move toward target position
			# Every tick/process
				# Check if we can attack
				# Check if we see 

func get_last_known_location():
	var last_location
	return last_location


# SEARCHING STATE
# move toward target's last known position
# check if we reached it, if so empty the last known location
func move_toward_target_last_known_position(self_position):
	move_toward_given_position(self_position, get_last_known_location())
	check_distance_to_target_last_known_location()
