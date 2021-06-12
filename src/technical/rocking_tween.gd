
class_name AnimationTween_SpriteVibrating
extends Tween

# customisable values for the tween
# anim duration determines how quickly it rocks from side to side
export(float, 0.1, 10.0) var anim_duration = 1.0
# anim max angle determines how far it rocks from side to side
export(int, 1, 180) var anim_max_angle = 15

# variables for controlling the tween
var rocking_anim_direction_left: bool = false
var rocking_anim_first_rock: bool = true

# variables for handling the target sprite/handling incorrect assignment
var sprite_to_rotate: Sprite
var is_active: bool = false

# unfinished and removed handlers for mid-tween stopping and starting
#  setget is_active_set
#
#func is_active_set(new_value):
#	is_active = new_value
#	if new_value == true and not self.is_active():
#		start_rocking_tween()
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
		sprite_to_rotate = get_parent()
		is_active = true
		start_rocking_tween()
	else:
		# console logging for debugging purposes
		if GlobalDebug.player_rocking_anim_tween: print("sprite rocking tween attached to non-sprite")


###############################################################################


# function to begin everything, gets called every tween loop
func start_rocking_tween() -> void:
	if is_active:
		# console logging for debugging purposes
		if GlobalDebug.player_rocking_anim_tween: print("sprite rocking tween start")
		# get starting point
		var starting_rotation = sprite_to_rotate.rotation_degrees
		
		# determine whether we're rocking left or right
		var set_new_rotation = starting_rotation + anim_max_angle \
		if rocking_anim_direction_left \
		else starting_rotation - anim_max_angle
		
		# if this is the first rocking it only needs to go half as far
		if rocking_anim_first_rock:
			set_new_rotation /= 2
			anim_duration /= 2
			rocking_anim_first_rock = false
		
		# tell the tween what to do and start it
		var _discard_value = interpolate_property(sprite_to_rotate, \
		"rotation_degrees", starting_rotation, set_new_rotation, \
		anim_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		# discard value is true
		_discard_value = start()
		# discard value is true
		
	else:
		# console logging for debugging purposes
		if GlobalDebug.player_rocking_anim_tween: print("sprite rocking tween attached but invalid")


# whenever the tween finishes need to flip the intended direction and restart it
func _on_RockingTween_tween_all_completed() -> void:
	# this shoudl be set if we get here
	if is_active:
		# console logging for debugging purposes
		if GlobalDebug.player_rocking_anim_tween: print("sprite rocking tween end")
		rocking_anim_direction_left = !rocking_anim_direction_left
		start_rocking_tween()
