extends Sprite

# how fast does the sprite rotate
export var rotation_intensity = 120
# how far is the texture offset
export var drawing_offset = 100

# can set randomisation of base values given above
var is_rotation_rate_randomised = true
var is_drawing_offset_randomised = true
# if randomisation is set, by what strength is it randomised
var random_bound_multiplier = 0.4

# for setting random colours
var base_green_hue = 0.9
var green_hue_fluctuation = 0.1
var base_red_hue = 0.8
var red_hue_fluctuation = 0.2

# what is the leaf scale set to initially - always 1:1 aspect ratio
var base_scale_setting = 0.3
# add or subtract up to this  from the base_scale_setting
var scale_modification_max_variance = 0.1

# what direction does the leaf head
var velocity = Vector2.ZERO
# how fast does the leaf drift
var base_movement_rate = 200

# if the leaf never enters screen, delete after this long
var failsafe_timer_duration = 10.0
# check whether it has entered screen before
var has_entered_screen = false
# check whether it is currently on screen
var is_currently_on_screen = false

# this must be enabled or sprite does not rotate
var is_rotating = true
# this must be enabled or sprite does not move
var is_moving = true
# this must be enabled or this sprite does nothing and is hidden
var is_active = true

onready var failsafe_deletion_timer = $FailsafeTimer

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_random_rotation_and_offset()
	set_sprite_offset()
	set_sprite_colour()
	set_sprite_scale()
	set_failsafe_deletion_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.visible = is_active
	if is_active:
		if is_rotating:
			self.rotation_degrees += (rotation_intensity * delta)
		if is_moving:
			self.position = position + (velocity * base_movement_rate * delta)

###############################################################################


# drawing offset for sprite
func set_sprite_offset():
	self.offset.x = drawing_offset
	self.offset.y = drawing_offset


# randomisation for sprite colour
func set_sprite_colour():
	# generate a random number between 0 and 3
	# this determines whether and what colour change happens
	var random_colour_choice = int(GlobalFuncs.ReturnRandomRange(0,3))
	#
	match random_colour_choice:
		# do nothing
		0:
			pass
		
		# use green hue randomisation
		1:
			self.modulate.g = set_sprite_colour_set_green_or_red_hue(true)
		# use yellow hue randomisation
		2:
			self.modulate.g = set_sprite_colour_set_green_or_red_hue(true)
			self.modulate.r = set_sprite_colour_set_green_or_red_hue(false)
		# use red hue randomisation
		3:
			self.modulate.r = set_sprite_colour_set_green_or_red_hue(false)


func set_sprite_colour_set_green_or_red_hue(is_green):
	# if not is_green, is_red, i.e. # var is_red = !is_green
	# get base value of hue
	var get_hue = base_green_hue if is_green else base_red_hue
	# get randomisation value
	var get_fluctuation = green_hue_fluctuation if is_green else red_hue_fluctuation
	# use the current green value to get between a % reduced amount
	# of the value and a % increased amount of the value
	var hue_random_floor = get_hue*(1-get_fluctuation)
	var hue_random_ceiling = get_hue*(1+get_fluctuation)
	# random between the two values
	var randomised_hue =\
	GlobalFuncs.ReturnRandomRange(hue_random_floor, hue_random_ceiling)
	# return the randomised hue
	return randomised_hue


func set_sprite_scale():
	# apply the scale variance to the base scale
	# calculate a minimum (floor) and maximum (celing) value
	var random_scale_floor = base_scale_setting-scale_modification_max_variance
	var random_scale_ceiling = base_scale_setting+scale_modification_max_variance
	# calculate a new scale value for the leaf from the above
	# generate random between floor and ceiling
	var effective_scale_mod =\
	 GlobalFuncs.ReturnRandomRange(random_scale_floor, random_scale_ceiling)
	# and set sprite scale to that
	scale = Vector2(effective_scale_mod, effective_scale_mod)


func set_failsafe_deletion_timer():
	failsafe_deletion_timer.wait_time = failsafe_timer_duration
	failsafe_deletion_timer.start()


# if set, establish random values of rotation rate and drawing offset
func set_random_rotation_and_offset():
	# for randomisation of rotation rate
	if is_rotation_rate_randomised:
		# multiply the rotation intensity by random_bound_multiplier as a
		# (float to) percentage, subtracting from 100% for lower bound and
		# adding to 100% for upper bound
		# e.g. 0.2 becomes 20% becomes lower bound 80% and upper bound 120%
		var rotation_minimum = rotation_intensity * (1-random_bound_multiplier)
		var rotation_maximum = rotation_intensity * (1+random_bound_multiplier)
		# set a new value using the rand_range modified func from globalfunc
		rotation_intensity =\
		 GlobalFuncs.ReturnRandomRange(rotation_minimum, rotation_maximum)
	
	# do the same as above but for the drawing offset
	if is_drawing_offset_randomised:
		var offset_minimum = drawing_offset * (1-random_bound_multiplier)
		var offset_maximum = drawing_offset * (1+random_bound_multiplier)
		drawing_offset =\
		GlobalFuncs.ReturnRandomRange(offset_minimum, offset_maximum)


###############################################################################


# entering the screen
func _on_VisibilityNotifier2D_screen_entered():
	# check that we've entered the screen
	has_entered_screen = true
	is_currently_on_screen = true


# exiting the screen
func _on_VisibilityNotifier2D_screen_exited():
	# if has already been on screen, delete self now we're done
	if has_entered_screen:
		delete_self()
	is_currently_on_screen = false


func _on_FailsafeTimer_timeout():
	if not is_currently_on_screen:
		delete_self()


###############################################################################


func delete_self():
	queue_free()

