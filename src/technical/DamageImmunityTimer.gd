extends Timer

signal successful_setup

export var immunity_duration = 1.0
export var total_flashes = 5
export var alpha_flash_on_tick = 0.25
export var alpha_flash_off_tick = 0.75

var is_active = false
var is_flashed_on = false
var flash_intermission

var sprite_parent
var sprite_base_alpha

onready var immunity_timer = self
onready var flash_timer = $FlashEffectTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_immunity_timer_and_children()


## testing
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if GlobalDebug.DEBUG_BUTTON_ENABLED:
#		if Input.is_action_just_pressed("debug"):
#			start_immunity()


###############################################################################


func set_immunity_timer_and_children():
	sprite_parent = get_parent()
	# if not null, wait until ready
	if sprite_parent != null:
		yield(sprite_parent, "ready")
	
	# parent is valid
	# set up node
	if sprite_parent is Sprite:
		flash_intermission = immunity_duration/total_flashes
		set_timer_parameters(immunity_timer, immunity_duration, false, true)
		set_timer_parameters(flash_timer, flash_intermission, false, true)
		is_active = true
		sprite_base_alpha = sprite_parent.modulate.a
		emit_signal("successful_setup")


func set_timer_parameters(timer_given, wait_duration, is_auto, is_oneshot):
	timer_given.wait_time = wait_duration
	timer_given.autostart = is_auto
	timer_given.one_shot = is_oneshot


###############################################################################


# reset base values
func _on_DamageImmunityTimer_timeout():
	if is_active:
		is_flashed_on = false
		print(sprite_parent)
		if sprite_base_alpha != null:
			sprite_parent.modulate.a = sprite_base_alpha
			sprite_base_alpha = null


# run flash effect
func _on_FlashEffectTimer_timeout():
	if is_active:
		flash_sprite()


###############################################################################


func start_immunity():
	if is_active and immunity_timer.is_stopped():
		immunity_timer.start()
		flash_timer.start()
		sprite_base_alpha = sprite_parent.modulate.a
		flash_sprite()


# run whenever we flash the sprite
func flash_sprite():
	# make sure we haven't stopped
	if is_active and not immunity_timer.is_stopped():
		# get alpha setting
		var alpha_set_value
		alpha_set_value =\
		 alpha_flash_on_tick if not is_flashed_on else alpha_flash_off_tick
		# flash parent
		is_flashed_on = !is_flashed_on
		sprite_parent.modulate.a = alpha_set_value
		# restart timer
		flash_timer.start()


###############################################################################


