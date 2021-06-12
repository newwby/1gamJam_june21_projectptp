
class_name AnimationTween_Spritevibrating
extends Tween

# customisable values for the tween
# anim duration determines how quickly it rocks from side to side
export(float, 0.1, 10.0) var anim_duration = 1.0
# anim max angle determines how far it rocks from side to side
export(int, 1, 180) var anim_max_pos_from_origin = 5

# variables for controlling the tween
var vibrating_anim_going_up: bool = false
var vibrating_anim_first_vibrate: bool = true

# if using multiple this stops them being in sync
var enable_random_offset = true
var duration_randomisation_range = 0.25
var travel_randomisation_range = 3

# variables for handling the target sprite/handling incorrect assignment
var sprite_to_vibrate: Sprite
var is_active: bool = false

# unfinished and removed handlers for mid-tween stopping and starting
#  setget is_active_set
#
#func is_active_set(new_value):
#	is_active = new_value
#	if new_value == true and not self.is_active():
#		start_vibrating_tween()
#	elif new_value == true and self.is_active():
#		self.resume_all()
#		self.is
#	elif new_value == false and self.is_active():
#		self.stop_all()


###############################################################################


# make sure the parent is ready and start the tween if so
func _ready() -> void:
	yield(get_parent(), "ready")
	if get_parent() is Sprite:
		sprite_to_vibrate = get_parent()
		set_random_offset()
		is_active = true
		start_vibrating_tween()
	else:
		# console logging for debugging purposes
		if GlobalDebug.player_vibrating_anim_tween: print("sprite vibrating tween attached to non-sprite")


###############################################################################

func set_random_offset():
	if enable_random_offset:
		var random_offset_in_range =\
		GlobalFuncs.ReturnRandomRange(-anim_max_pos_from_origin, anim_max_pos_from_origin)
		sprite_to_vibrate.position.y = random_offset_in_range
		
		var duration_random_offset =\
		GlobalFuncs.ReturnRandomRange(-duration_randomisation_range, duration_randomisation_range)
		anim_duration += duration_random_offset
		
		var travel_random_offset =\
		GlobalFuncs.ReturnRandomRange(-travel_randomisation_range, travel_randomisation_range)
		anim_max_pos_from_origin += travel_random_offset


# function to begin everything, gets called every tween loop
func start_vibrating_tween() -> void:
	if is_active:
		# console logging for debugging purposes
		if GlobalDebug.player_vibrating_anim_tween: print("sprite vibrating tween start")
		# get starting point
		var starting_height = sprite_to_vibrate.position.y
		
		# determine whether we're vibrating left or right
		var set_new_height = starting_height + anim_max_pos_from_origin \
		if vibrating_anim_going_up \
		else starting_height - anim_max_pos_from_origin
		
		# if this is the first vibrating it only needs to go half as far
		if vibrating_anim_first_vibrate:
			set_new_height /= 2
			anim_duration /= 2
			vibrating_anim_first_vibrate = false
		
		# tell the tween what to do and start it
		var _discard_value = interpolate_property(sprite_to_vibrate, \
		"position:y", starting_height, set_new_height, \
		anim_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		# discard value is true
		_discard_value = start()
		# discard value is true
		
	else:
		# console logging for debugging purposes
		if GlobalDebug.player_vibrating_anim_tween: print("sprite vibrating tween attached but invalid")


# whenever the tween finishes need to flip the intended direction and restart it
func _on_VibratingTween_tween_all_completed() -> void:
	# this shoudl be set if we get here
	if is_active:
		# console logging for debugging purposes
		if GlobalDebug.player_vibrating_anim_tween: print("sprite vibrating tween end")
		vibrating_anim_going_up = !vibrating_anim_going_up
		start_vibrating_tween()
