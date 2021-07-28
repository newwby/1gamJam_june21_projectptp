
class_name StateRoaming, "res://art/shrek_pup_eye_sprite.png"
extends StateParent

export var roaming_max_range = 400
export var roaming_wait_delay = 2.0
export var roaming_wait_delay_randomness = 1.5
export var roaming_max_duration = 4.0

var roaming_target_position = Vector2.ZERO
var distance_to_roaming_target_to_complete = 25
var distance_to_during_last_frame = null
var can_roam_again = false
var has_roam_target = false

onready var roaming_wait_delay_timer = $BetweenRoamTimer
onready var roaming_duration_timer = $MaxRoamTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_roaming_wait_delay_timer()
	set_roaming_duration_timer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

###############################################################################

# set the state priority
func set_state_priority():
	state_priority = 20


# if the state has a specific state emote, set the texture here
func set_state_emote_position():
	if not is_active:
		yield(enemy_parent_node, "ready")
	state_emote_node = $StateEmote
	state_emote_node.position = enemy_parent_node.hud_gfx_pos2d.position


# call this whenever timer expires
func set_roaming_wait_delay_timer():
	# get a random modifier to apply to wait timer
	var delay_randomness =\
	 GlobalFuncs.ReturnRandomRange(\
	-roaming_wait_delay_randomness, roaming_wait_delay_randomness)
	# apply base with randomness added
	roaming_wait_delay_timer.wait_time = roaming_wait_delay+delay_randomness


# call on setup
func set_roaming_duration_timer():
	roaming_duration_timer.wait_time = roaming_max_duration


################################################################################


func _on_BetweenRoamTimer_timeout():
	set_roaming_wait_delay_timer()
	can_roam_again = true


func _on_MaxRoamTimer_timeout():
	clear_roam_target()


################################################################################


## placeholder function to be derived by child classes
## returns false without any superseding child class function
func check_state_condition():
	pass
#
#
## placeholder function to be derived by child classes
func state_action():
	if can_roam_again and not has_roam_target:
		set_new_roam_target()
	elif has_roam_target:
		if check_distance_to_roam_target():
			clear_roam_target()
		else:
			move_toward_roam_target()
	else:
		if roaming_wait_delay_timer.is_stopped() and can_roam_again == false:
			roaming_wait_delay_timer.start()


################################################################################


func check_distance_to_roam_target():
	var is_close_enough_to_stop = false
	var self_pos = enemy_parent_node.position
	# are we close enough to stop
	var current_distance_to = self_pos.distance_to(roaming_target_position)
	
	# if close enough
	if current_distance_to < distance_to_roaming_target_to_complete:
		is_close_enough_to_stop = true
	# or if haven't moved far enough
	elif distance_to_during_last_frame != null\
	and	abs(distance_to_during_last_frame) - abs(current_distance_to) < 0.5:
		is_close_enough_to_stop = true
	
	# for next frame
	distance_to_during_last_frame = current_distance_to
	return is_close_enough_to_stop


func move_toward_roam_target():
	var self_pos = enemy_parent_node.position
	if roaming_target_position != Vector2.ZERO:
		enemy_parent_node.move_toward_given_position(self_pos, roaming_target_position)


func set_new_roam_target():
	clear_roam_target()
	var self_pos = enemy_parent_node.position
	var roam_range_share = roaming_max_range/2
	# get distance to roam
	var roam_x_axis = GlobalFuncs.ReturnRandomRange(\
	-roam_range_share, roam_range_share)
	var roam_y_axis = GlobalFuncs.ReturnRandomRange(\
	-roam_range_share, roam_range_share)
	# set new roaming target
	roaming_target_position = Vector2(\
	self_pos.x + roam_x_axis,\
	self_pos.y + roam_y_axis)
	# set var, start timer
	can_roam_again = false
	has_roam_target = true
	roaming_duration_timer.start()


func clear_roam_target():
	roaming_target_position = false
	has_roam_target = false
	enemy_parent_node.velocity = Vector2.ZERO
	distance_to_during_last_frame = null
	roaming_wait_delay_timer.start()
