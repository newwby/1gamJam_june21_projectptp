extends Tween

# customisable length of the tween before it inverts
export var tween_duration = 0.5
# start tween automatically or wait for manual call?
export var autostart = true
# the scale difference between start and end state
export var scale_difference = Vector2(0.05, 0.05)

# removed from pulse tween
# a version of the pulse/rock/squish/vibrating tween built for extensibility
# and further moddability would be great
# (they are basically the same code with minor edits)
#export var active_tween_speed_override = 2.0
#export var passive_tween_speed_override = 1.0

# get self (the tween)
var pulse_animation_tween = self
# the parent sprite node of the tween
var target_sprite
# if all set functions run, active status is set
# tween will not run automatically without is_active
var is_active = false

# inverts which is the start and which is the end value
var invert_tween = false
## scale of target sprite
#var initial_scale: Vector2
# tween moves from start to end
var starting_scale: Vector2
var ending_scale: Vector2

#############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	 # initial_setup
	set_node()
	# begin animation process
	if is_active and autostart:
		start_tween()


#############################################################################


# validate parent node to start tween
func set_node():
	# removed code as initial scale not useful when we get the scale
	# each time the tween is called
#	if set_target_sprite_from_parent_node()\
#	and set_initial_scale():
#		is_active = true
	if set_target_sprite_from_parent_node():
		is_active = true


# check if the tween has a valid parent node
func set_target_sprite_from_parent_node():
	target_sprite = get_parent()
	if target_sprite != null and target_sprite is Sprite:
		return true
	else:
		return false

## check if we have a target sprite with a valid scale to store
#func set_initial_scale():
#	if target_sprite != null:
#		initial_scale = target_sprite.scale
#	if initial_scale != null:
#		return true
#	else:
#		return false


#############################################################################


func _on_AnimationTween_SpritePulsing_tween_all_completed():
	invert_tween = !invert_tween
	start_tween()


#############################################################################


func start_tween():
	if is_active:
		starting_scale = target_sprite.scale
		# subtract scale adj if inverting tween else add it
		var new_scale_adjustment = \
		-scale_difference if invert_tween else scale_difference
		# calculate end point
		ending_scale = starting_scale + new_scale_adjustment
		
		# begin tween
		pulse_animation_tween.interpolate_property(target_sprite, \
		"scale", starting_scale, ending_scale, \
		tween_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		pulse_animation_tween.start()

