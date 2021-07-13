
extends Tween

var is_active = false

#var squish_range = 0.10
var invert_squish = false

var target_sprite
export var squish_randomness_cap = 0.05
export var sprite_rescale_x = 0.75
export var sprite_rescale_y = 0.75
export var active_tween_speed_override = 2.0
export var passive_tween_speed_override = 1.0

var horizontal_squish = Vector2(1.05, 0.95)
var vertical_squish = Vector2(0.95, 1.05)

var squish_duration  = 0.5
var squish_tween = self


# Called when the node enters the scene tree for the first time.
func _ready():
#	set_squish_coefficients()
	set_squish_randomness()
	start_squish_tween()


###############################################################################

#
#func set_squish_coefficients():
#	var min_squish_coefficient = 1.0 - squish_range/2
#	var max_squish_coefficient = 1.0 + squish_range/2
#	horizontal_squish = Vector2(max_squish_coefficient, min_squish_coefficient)
#	vertical_squish = Vector2(min_squish_coefficient, max_squish_coefficient)


func set_squish_randomness():
	var random_squish =\
	 GlobalFuncs.ReturnRandomRange(\
	 -squish_randomness_cap, squish_randomness_cap)
	
	if random_squish < 0.03 and random_squish > 0:
		random_squish += 0.03
	elif random_squish < 0 and random_squish > -0.03:
		random_squish -= 0.03
	
	horizontal_squish = Vector2(\
	sprite_rescale_x - random_squish, sprite_rescale_y + random_squish)
	vertical_squish = Vector2(\
	sprite_rescale_x + random_squish, sprite_rescale_y - random_squish)
	squish_duration += random_squish

###############################################################################


func _on_SquishingTween_tween_all_completed():
	invert_squish = !invert_squish
	run_squish_tween()


###############################################################################


func start_squish_tween():
	if get_parent() is Sprite:
		target_sprite = owner
		is_active = true
	if is_active:
		squish_tween.playback_speed = passive_tween_speed_override
		run_squish_tween()


###############################################################################


func run_squish_tween():
	var start_scale = horizontal_squish if invert_squish else vertical_squish
	var end_scale = vertical_squish if invert_squish else horizontal_squish
	squish_tween.interpolate_property(target_sprite, "scale",\
	 start_scale, end_scale, squish_duration,\
	 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	squish_tween.start()
