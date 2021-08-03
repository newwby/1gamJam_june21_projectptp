
class_name StateSearching, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

# stop searching after this
onready var search_state_first_phase = $SearchTimer

var is_searching = false

var search_timer_duration = 3.0
var distance_to_last_seen_location = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	set_search_timer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################


# set the state priority
func set_state_priority():
	state_priority = 30


# if the state has a specific state emote, set the texture here
func set_state_emote_position():
	if not is_active:
		yield(enemy_parent_node, "ready")
	state_emote_node = $StateEmote
	state_emote_node.position = enemy_parent_node.hud_gfx_pos2d.position


func set_search_timer():
	search_state_first_phase.wait_time = search_timer_duration

#
################################################################################
##
#
### placeholder function to be derived by child classes
### returns false without any superseding child class function
func check_state_condition():
	if is_active:
		if enemy_parent_node.current_target == null:
			return true
	return false
##
##
### placeholder function to be derived by child classes
func state_action():
	# position based logic
	move_toward_target_location_and_stop()
	# timer based logic
#	if not search_state_first_phase.is_stopped() and not is_searching:
#		move_toward_target_location_for_duration()
#		search_state_first_phase.start()
#		is_searching = true


func move_toward_target_location_and_stop():
	# get enemy parent node's position
	var self_pos = enemy_parent_node.position
	# get player last known location
	var target_pos = detection_manager.target_last_known_location
	# are we close enough to end state
	if target_pos != null:
		# if close enough
		if self_pos.distance_to(target_pos) < distance_to_last_seen_location:
			clear_search_state()
		else:
			# move toward that position
			enemy_parent_node.move_toward_given_position(self_pos, target_pos)
		# if not close enough we just check again later
		# (should this check be time gated for performance?)
	else:
#		print("we don't know where target is why are we in this state")
		clear_search_state()


func move_toward_target_location_for_duration():
	# get enemy parent node's position
	var self_pos = enemy_parent_node.position
	# get player last known location
	var target_pos = detection_manager.target_last_known_location
	# move toward that position
	enemy_parent_node.move_toward_given_position(self_pos, target_pos)


func _on_SearchTimer_timeout():
	clear_search_state()


func clear_search_state():
	if state_manager_node.current_state == StateManager.State.SEARCHING:
		detection_manager.target_last_known_location = null
		enemy_parent_node.velocity = Vector2.ZERO
		state_manager_node.set_new_state(StateManager.State.ROAMING)
