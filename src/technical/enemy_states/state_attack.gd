
class_name StateAttack, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

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

# set the state priority
func set_state_priority():
	state_priority = 50
#
#
################################################################################
#
## placeholder function to be derived by child classes
## returns false without any superseding child class function
func check_state_condition():
	var get_weapon_node = enemy_parent_node.weapon_node
	
	var get_target = detection_manager.current_target
	var firing_target = detection_manager.target_last_known_location
	
	if get_target != null and firing_target != null\
	and get_weapon_node.activation_timer.is_stopped():
		print("true")
		return true
	else:
		print("false")
		return false
#
#
## placeholder function to be derived by child classes
func state_action():
	if is_active:
		if enemy_parent_node != null:# and detection_manager != null:
			var get_weapon_node = enemy_parent_node.weapon_node
			var get_target = detection_manager.current_target
#			print("find target", detection_manager, get_target, detection_manager.current_target)
			var firing_target = detection_manager.target_last_known_location
			if get_target != null and firing_target != null:
				enemy_parent_node.current_mouse_target = -(firing_target)
				enemy_parent_node.firing_target = -(firing_target)
#				print("FIRE!")
				get_weapon_node.attempt_ability()
			else:
				# need to check for new state
				emit_signal("check_state")
#	get_weapon_node
