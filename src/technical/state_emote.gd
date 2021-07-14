extends Node2D

enum StateTexture {ROAMING, SEARCHING, HUNTING}

export(StateTexture) var chosen_state_texture

export var is_enabled = true
export var pos_y_travel_px = 20
export var tween_anim_duration = 0.75

var pos_y_start
var pos_y_end
var alpha_start = 1.0
var alpha_end = 0

onready var state_emote_sprite = $Sprite
onready var movement_handler_tween = $Sprite/AnimationTween


###############################################################################


func _ready():
	start_tween()


###############################################################################


func set_base_values():
	pos_y_start = 0
	pos_y_end = pos_y_start-pos_y_travel_px

func set_new_texture():
	var new_texture
	match chosen_state_texture:
		StateTexture.ROAMING:
			new_texture = load(GlobalReferences.state_emote_roaming)
		StateTexture.SEARCHING:
			new_texture = load(GlobalReferences.state_emote_searching)
		StateTexture.HUNTING:
			new_texture = load(GlobalReferences.state_emote_hunting)
	
	state_emote_sprite.texture = new_texture


###############################################################################


func start_tween():
	if is_enabled:
		set_new_texture()
		set_base_values()
		self.visible = true
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
