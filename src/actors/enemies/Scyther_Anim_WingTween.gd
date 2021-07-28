extends Node2D

var invert = false
var rotation_strength = 25
var upward_strength = 15
var flap_duration = 0.2

onready var wing_tween = $WingTween
onready var sprite_left_wing = $LeftWing
onready var sprite_right_wing = $RightWing


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_left_wing.rotation_degrees = -rotation_strength/2
	sprite_right_wing.rotation_degrees = -rotation_strength/2
	start_tween()


###############################################################################


func _on_WingTween_tween_all_completed():
	invert = !invert
	start_tween()


###############################################################################


func start_tween():
	var rotation_effect
	var y_axis_effect
	var base_rotate_position
	var adj_rotate_position
	var base_y_position
	var adj_y_position
	
	if invert:
		rotation_effect = -rotation_strength
		y_axis_effect = -upward_strength
	else:
		rotation_effect = rotation_strength
		y_axis_effect = upward_strength
	
	base_rotate_position = sprite_left_wing.rotation_degrees
	adj_rotate_position = base_rotate_position + rotation_effect
	base_y_position = sprite_left_wing.position.y
	adj_y_position = base_y_position + y_axis_effect
	
	wing_tween.interpolate_property(sprite_left_wing, "rotation_degrees", \
	base_rotate_position, adj_rotate_position, flap_duration, \
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	wing_tween.interpolate_property(sprite_right_wing, "position:y", \
	base_y_position, adj_y_position, flap_duration, \
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	base_rotate_position = sprite_right_wing.rotation_degrees
	adj_rotate_position = base_rotate_position + rotation_effect
	base_y_position = sprite_right_wing.position.y
	adj_y_position = base_y_position + y_axis_effect
	
	wing_tween.interpolate_property(sprite_right_wing, "rotation_degrees", \
	base_rotate_position, adj_rotate_position, flap_duration, \
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	wing_tween.interpolate_property(sprite_right_wing, "position:y", \
	base_y_position, adj_y_position, flap_duration, \
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	wing_tween.start()
