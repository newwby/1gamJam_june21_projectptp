
class_name State_Hunting, "res://art/shrek_pup_eye_sprite.png"
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


func _state_action(enemy_node = null, current_target = null):
	move_and_track_target(enemy_node.position, current_target)


# check if can hunt
func _state_check(current_target, target_last_known_pos, current_state):
	# check
	if current_target != null\
	 and current_state != Enemy.State.HUNT:
		return true
	else:
		return false



# HUNTING STATE
# move toward target, keep looking at target, try to fire
func move_and_track_target(self_position, current_target):
	# If not firing - Do we have a target?
	# Move toward target
	# Every tick/process
		# Check if we can attack
		# Update our target position
	if current_target != null:
		move_toward_given_position(self_position, current_target.position)
		check_if_can_still_see_target(current_target)
		# move this to parent, check after move_and_track
#		signal check_if_weapon_can_fire()
			# if no recheck_state
		# move this to parent, check after move_and_track
#		signal recheck_state()



# checks to see if target is at near range
func check_if_can_still_see_target(check_target):
	pass
