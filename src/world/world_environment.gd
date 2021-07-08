extends Node2D

signal game_started

var fade_zero = 0
var fade_max = 1.0

var start_timer_dur = 1.5
var logo_fade_tween_dur = 0.5
var tween_ui_fade_in_dur = 1.5
var tween_bkg_fade_in_dur = tween_ui_fade_in_dur/2

onready var start_timer = $TempFade/StartTimer

onready var opening_logo_tween = $TempFade/OpeningCamera/OpeningCanvasLayer/OpeningLogoTween
onready var game_splash_logo = $TempFade/OpeningCamera/OpeningCanvasLayer/GameSplashSprite
onready var opening_camera = $TempFade/OpeningCamera

onready var bkg_fade = $TempFade/FadeBlkBkg
onready var fade_in = $TempFade/FadeInTween

onready var player_node = $Player
onready var ui_node = $Player/UICanvasLayer/PlayerHUD
onready var game_camera = $GameCamera2D

onready var background_music = $BackgroundBGM

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	starting_game_splash_fade_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


# part 1, on ready
func starting_game_splash_fade_in():
	start_timer.wait_time = start_timer_dur
	ui_node.modulate.a = fade_zero
	player_node.visible = true
	ui_node.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_timer.start()


# part 2, after duration
func _on_StartTimer_timeout():
	opening_logo_tween.interpolate_property(game_splash_logo,"modulate:a",\
	fade_max, fade_zero, logo_fade_tween_dur,\
	Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	opening_logo_tween.start()

# part 3, after fade tween
func _on_OpeningLogoTween_tween_all_completed():
	opening_camera.current = false
	game_camera.current = true
	game_camera.camera_target = player_node
	
	fade_in.interpolate_property(ui_node,"modulate:a",\
	fade_zero, fade_max, tween_ui_fade_in_dur,\
	Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	
	fade_in.interpolate_property(bkg_fade,"modulate:a",\
	fade_max, fade_zero, tween_bkg_fade_in_dur,\
	Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	
	if GlobalDebug.MUSIC_ENABLED:
		background_music.play()
	fade_in.start()


# part 4
# we don't care if both tweens finished
# let player start moving immediately
# game go!
func _on_FadeInTween_tween_completed(_object, _key):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var all_actors = get_tree().get_nodes_in_group("actors")
	for actor_node in all_actors:
		actor_node.is_active = true
	emit_signal("game_started")
