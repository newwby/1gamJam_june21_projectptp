
class_name ActiveAbility
extends BaseAbility

signal activate_signal(ability_type)

var current_ability_loadout

# reference a string path held elsewhere (for simpler path changes)
const MODIFIER_TIME_SLOW_PATH = GlobalReferences.modifier_time_slow

# graphical settings for the time bubble effect
var time_bubble_sprite_base_scale = Vector2(1.0, 1.0)
var time_bubble_sprite_base_alpha_value = 0.5
var time_bubble_sprite_tween_scale_ceiling = Vector2(4.0, 4.0)
var time_bubble_sprite_tween_alpha_floor = 0.05
var time_bubble_sprite_tween_duration = 0.15

# resource path of the projectile actors can spawn
onready var modifier_time_slow_object = preload(MODIFIER_TIME_SLOW_PATH)

	
onready var blink_particle_effect = $BlinkParticles
onready var time_bubble_effect_sprite = $TimeBubbleExpansion
onready var time_bubble_effect_tween = $TimeBubbleExpansion/BubbleFadeTween

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_ability_type()
	set_ability_effects()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


# active ability
func activate_ability():
	.activate_ability()
	if GlobalDebug.player_active_ability_logs: print(name, " (ability) is activated!")
	if current_ability_loadout == GlobalVariables.AbilityTypes.BLINK:
		call_ability_blink()
	if current_ability_loadout == GlobalVariables.AbilityTypes.TIME_SLOW:
		call_ability_time_slow()


###############################################################################


func set_ability_type():
	my_ability_type = AbilityType.ACTIVE


func set_new_ability(ability_id):
	current_ability_loadout = ability_id


# initial setup of all ability effects
func set_ability_effects():
	set_blink_particles()
	set_time_bubble_sprite()


# resets the blink ability particles
func set_blink_particles():
	# hide blink particles
	blink_particle_effect.emitting = false
	blink_particle_effect.visible = false

# resets the time bubble effect sprite
func set_time_bubble_sprite():
	time_bubble_effect_sprite.visible = false
	time_bubble_effect_sprite.modulate.a = time_bubble_sprite_base_alpha_value
	time_bubble_effect_sprite.rect_scale = time_bubble_sprite_base_scale


###############################################################################


func _on_BubbleFadeTween_tween_all_completed():
	set_time_bubble_sprite()


###############################################################################


# the blink dodge is an ability that lets a player avoid enemy fire
# and move with great speed in one direction for a brief duration
func call_ability_blink():
	# get the heading we're going to blink toward
	var new_velocity =\
	 get_global_mouse_position() - owner.position
	
	var particle_direction = new_velocity.normalized()
	blink_particle_effect.emitting = true
	blink_particle_effect.visible = true
	#
	blink_particle_effect.one_shot = false
	blink_particle_effect.one_shot = true
	blink_particle_effect.direction = -particle_direction
	
	# disable collision with everything except walls/obstacles
	owner.set_collision_mask_bit(2, false)
	owner.set_collision_mask_bit(3, false)
	owner.set_collision_mask_bit(5, false)
	owner.set_collision_mask_bit(7, false)
	# repurpose with this
	##my_area.set_collision_mask_bit(Layer.WALLS, true)
	
	# create a timer and set properties for this function
	var blink_timer = Timer.new()
	self.add_child(blink_timer)
	blink_timer.wait_time = 0.0075
	blink_timer.autostart = false
	blink_timer.one_shot = true
	
	# no taking damage during a dodge blink
	owner.is_damageable_by_foes = false
	
	# start a loop for movement iteration
	var loop_count = 9
	var current_loop = 0
	# exit condition for the loop
	while current_loop < loop_count:
		
		if owner.visible and owner.modulate.a < 0.5:
			owner.visible = false
		elif owner.visible and owner.modulate.a >= 0.5:
			owner.modulate.a = 0.4
		else:
			owner.visible = true
			owner.modulate.a = 1.0
		
		# move the actor in tiny steps
		owner.position += (new_velocity.normalized() * (owner.movement_speed)*0.15)
		# start the timer
		blink_timer.start()
		# wait until it is finished
		yield(blink_timer, "timeout")
		# sound
		emit_signal("activate_signal", "blink")
		# repeat loop until this hits condition
		current_loop += 1
	
	# TODO fix this it does not work
	# reenable collision with everything except walls/obstacles
	owner.set_collision_mask_bit(2, true)
	owner.set_collision_mask_bit(3, true)
	owner.set_collision_mask_bit(5, true)
	owner.set_collision_mask_bit(7, true)

	# reset actor properties modified within this function
	owner.is_damageable_by_foes = true
	owner.visible = true
	owner.modulate.a = 1.0
	
	self.remove_child(blink_timer)
	blink_timer.queue_free()


# ability code for time slow below


# function for slowing time
func call_ability_time_slow():
	
	time_slow_bubble_effect()
	
	# call actor speed func on all actors active
	# TODO exclude actor who called this ability
	var group_to_call = get_tree().get_nodes_in_group("actors")
	# call	
	for actor in group_to_call:
		if actor != self.owner:
			time_slow_actor_speed(actor)

	# call projectile speed func on all projectiles active
	group_to_call = get_tree().get_nodes_in_group("projectiles")
	for projectile in group_to_call:
		if projectile.projectile_owner != self.owner:
			time_slow_projectile_speed(projectile)
	# TODO handle newly created things between start and expiry
	emit_signal("activate_signal", "time_slow")


###############################################################################


func time_slow_bubble_effect():
	time_bubble_effect_sprite.visible = true
	
	# scale tween - rapidly expand the sprite
	time_bubble_effect_tween.interpolate_property( \
	time_bubble_effect_sprite,"rect_scale", \
	time_bubble_sprite_base_scale, time_bubble_sprite_tween_scale_ceiling, \
	time_bubble_sprite_tween_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	# fade out tween - rapidly fade away the sprite
	time_bubble_effect_tween.interpolate_property( \
	time_bubble_effect_sprite,"modulate:a", \
	time_bubble_sprite_base_alpha_value, time_bubble_sprite_tween_alpha_floor, \
	time_bubble_sprite_tween_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	# start both tweens
	time_bubble_effect_tween.start()
	
#var time_bubble_sprite_tween_scale_ceiling = Vector2(3.0, 3.0)
#var time_bubble_sprite_tween_alpha_floor = 0.05
#var time_bubble_sprite_tween_duration = 0.5


# function for slowing actor movement speed
func time_slow_actor_speed(target):
	var original_speed = target.movement_speed
	var new_speed = (target.movement_speed)*0.25
	target.movement_speed = new_speed
	
	var timertemp = Timer.new()
	target.add_child(timertemp)
	timertemp.wait_time = 0.75
	timertemp.one_shot = true
	timertemp.start()
	yield(timertemp, "timeout")
	
	timertemp.queue_free()
	target.movement_speed = original_speed


# function for slowing projectile flight speed and rotation speed
func time_slow_projectile_speed(target):
	var original_flight_speed = target.projectile_speed
	var original_rotation_speed = target.rotation_per_tick
	var new_flight_speed = (target.projectile_speed)*0.25
	var new_rotation_speed = (target.rotation_per_tick)*0.25
	
	target.projectile_speed = new_flight_speed
	target.rotation_per_tick = new_rotation_speed
	#haven't slowed orbit rotation
#	target.owner.orbiting_rotation_rate = 1
	
	var timertemp = Timer.new()
	target.add_child(timertemp)
	timertemp.wait_time = 0.75
	timertemp.one_shot = true
	timertemp.start()
	yield(timertemp, "timeout")
	
	timertemp.queue_free()
	target.projectile_speed = original_flight_speed
	target.rotation_per_tick = original_rotation_speed
	#haven't slowed orbit rotation
#	target.owner.orbiting_rotation_rate = 3

###############################################################################


#	get_tree().call_group("actors", set_actor_move_speed_slowed())
#	get_tree().call_group("projectiles", set_projectile_flight_speed_slowed())
#	get_tree().call_group("projectiles", set_projectile_rotator_orbit_speed_slowed())


	# TODO fix the time slow implementation
	# it should be an object created on everything
	# not a singleton that calls all
#func defunct_create_time_slow_mod(target):
#	var time_slow_instance = modifier_time_slow_object.instance()
#	target.add_child(time_slow_instance)
