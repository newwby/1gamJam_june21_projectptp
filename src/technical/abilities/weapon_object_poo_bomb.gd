extends Area2D

export var total_bomb_lifespan = 8.0
export var explode_on_natural_expiry = true
export var can_hurt_allies = true

var bomb_owner
var bomb_damage = 40

var time_between_trigger_and_explode = 1.0
var flash_step_interval = 0.2

var flash_tween_running = true
var anim_is_flashed = false
var base_modulate
# color settings when flashing
var flash_modulate = Color(50, 50, 50, 0.5)

# values for explosion anim tween
# duration
var duration_explode_tween = 0.5
# scale
var base_explode_tween_scale = Vector2(0.6, 0.6)
var end_explode_tween_scale = Vector2(1.2, 1.2)
# alpha
var base_explode_tween_alpha = 1.0
var end_explode_tween_alpha = 0.05

var anim_tween_pulse_playback_speed_accelerated = 2.0

onready var hitbox = $CollisionShape2D
onready var explosion_area = $DamageArea
onready var explosion_collision = $DamageArea/CollisionShape2D
onready var sprite_gfx = $Sprite
onready var explosion_animated_sprite = $ExplosionAnimation
onready var anim_tween_pulse = $Sprite/AnimationTween_SpritePulsing
onready var anim_tween_explode = $ExplosionAnimation/ExplosionTween
onready var timer_countdown = $ExplosionAnimation/OnTriggerTimeToExplode
onready var timer_flash_steps = $ExplosionAnimation/TriggeredFlashStepTimer
onready var timer_lifespan = $TotalLifespan
onready var sound_effect_triggered = $TriggeredSE
onready var sound_effect_explodes = $ExplosionAnimation/ExplosionSE

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# set up timers to use
	set_initial_timer_values()
	# store sprite colour values
	set_base_sprite_color_values()
	# begin lifespn countdown
	timer_lifespan.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


func set_initial_timer_values():
	timer_countdown.wait_time = time_between_trigger_and_explode
	timer_flash_steps.wait_time = flash_step_interval
	timer_lifespan.wait_time = total_bomb_lifespan


func set_base_sprite_color_values():
	base_modulate = sprite_gfx.modulate


###############################################################################


func _on_PooBomb_body_entered(body):
	# make sure not player, if it isn't, trigger it!
	if not body is Player:
		#disable collision
		hitbox.disabled = true
		#trigger countdown
		begin_countdown()


func _on_ExplosionTween_tween_all_completed():
	# at this point the explosion animation is finished
	# the node can be shut down (collision etc)
	# then freed from queue
	explosion_collision.disabled = true
	call_deferred("queue_free")


# countdown timer runs out
func _on_OnTriggerTimeToExplode_timeout():
	explode()


# flash timer runs out; flashes sprite on and off
# this runs repeatedly during countdown timer
func _on_TriggeredFlashStepTimer_timeout():
	if not timer_countdown.is_stopped():
		anim_is_flashed = !anim_is_flashed
		if anim_is_flashed:
			sprite_gfx.modulate = base_modulate
		elif not anim_is_flashed:
			sprite_gfx.modulate = flash_modulate
	# don't bother if the countdown isn't running
		timer_flash_steps.start()
	else:
		sprite_gfx.modulate = base_modulate


# explode bomb if it has been sitting out too long?
func _on_TotalLifespan_timeout():
	if explode_on_natural_expiry:
		begin_countdown()
	else:
		# no animation atm this will look sudden
		queue_free()


###############################################################################


# flash white play triggered sound
func begin_countdown():
	# play the triggered sound effect
	sound_effect_triggered.play()
	
	# accelerate the pulse tween
	var original_playback_speed = anim_tween_pulse.playback_speed
	var accelerated_playback_speed = original_playback_speed*2
	anim_tween_pulse.playback_speed = accelerated_playback_speed
	
	# start timer for explosion (timer countdown)
	timer_countdown.start()
	# flash alternating (use timer flash steps)
	timer_flash_steps.start()


# explode in aoe
func explode():
	# sound effect play
	anim_tween_pulse.stop_all()
	sound_effect_explodes.play()
	explosion_animated_sprite.playing = true
	
#	var temp_base_et_scale = Vector2(0.5, 0.5)
#	var temp_end_et_scale = Vector2(1.0, 1.0)
	
#	explosion_animated_sprite.scale = temp_base_et_scale
	# set explosion animation tween for scale
	anim_tween_explode.interpolate_property(explosion_animated_sprite, \
	"scale", base_explode_tween_scale, end_explode_tween_scale, \
	duration_explode_tween, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	anim_tween_explode.start()
	
	# set explosion animation tween for alpha
	anim_tween_explode.interpolate_property(explosion_animated_sprite, \
	"modulate:a", base_explode_tween_alpha, end_explode_tween_alpha, \
	duration_explode_tween, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	# start explosion animation tween and show the explosion
	anim_tween_explode.start()
	sprite_gfx.visible = false
	explosion_animated_sprite.visible = true
	explosion_collision.disabled = false
	
	# start tween
	# tween duration length of animation play time (frames / fps) or multiple
	# aoe collision triggered


func _on_DamageArea_body_entered(body):
	if body != null:
		if body is Enemy\
		or body is Player and can_hurt_allies:
			body.emit_signal("damaged", bomb_damage, bomb_owner)
