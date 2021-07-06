
class_name StateSearching, "res://art/shrek_pup_eye_sprite.png"
extends StateParent


# stop searching after this
onready var search_state_first_phase = $SearchTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# set the state priority
func set_state_priority():
	state_priority = 30
#
#
################################################################################
##
# TODO REVIEW is the search state implemented? implement if so
# TODO TASK reimplement roaming/wandering state
#
### placeholder function to be derived by child classes
### returns false without any superseding child class function
#func check_state_condition():
#	if is_active:
#		if enemy_parent_node.current_target == null:
#			return true
#	return false
##
##
### placeholder function to be derived by child classes
#func state_action():
#	var detector = enemy_parent_node.detection_scan
#	enemy_parent_node.current_target =\
#	 detector.get_closest_player_in_near_group()


func start_timer():
	search_state_first_phase.start()


func _on_SearchTimer_timeout():
	if state_manager_node.current_state == StateManager.State.SEARCHING:
		state_manager_node.set_new_state(StateManager.State.IDLE)
