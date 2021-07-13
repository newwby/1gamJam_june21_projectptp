extends Position2D

onready var state_emote_sprite = $Sprite
onready var movement_handler_tween = $Sprite/AnimationTween

export var pos_y_travel_px = 20
export var tween_anim_duration = 0.75

var pos_y_start
var pos_y_end
var alpha_start = 1.0
var alpha_end = 0


###############################################################################


func _ready():
	start_tween()


###############################################################################


func set_base_values():
	pos_y_start = 0
	pos_y_end = pos_y_start-pos_y_travel_px


func set_new_texture(given_texture):
	state_emote_sprite.texture = load(given_texture)


###############################################################################


func start_tween():
	self.visible = true
	set_base_values()
	run_tween_on_self()


###############################################################################


func run_tween_on_self():
	if not movement_handler_tween.is_active():
		
		movement_handler_tween.interpolate_property(state_emote_sprite, "position:y",\
		 pos_y_start, pos_y_end, tween_anim_duration,\
		 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
		movement_handler_tween.interpolate_property(state_emote_sprite, "modulate:a",\
		 alpha_start, alpha_end, tween_anim_duration,\
		 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
		movement_handler_tween.start()


func _on_AnimationTween_tween_all_completed():
	self.visible = false
#	pass
