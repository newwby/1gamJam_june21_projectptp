extends Node2D

var is_active = false

var sprite_size
var tween_anim_duration = 0.75
var time_bubble_group_id = "time_bubble_"

var ability_duration = 40.0

onready var debug_underlay = $DebuggingRect
onready var sprite_node = $DistortionSprite
onready var bubble_collision = $Area2D/CollisionShape2D
onready var anim_tween = $AnimationTween
onready var lifespan_timer = $LifespanTimer

"""
Outline Border Shader by hiulit/outline-gles2.shader
https://gist.github.com/hiulit/5b8fbcd40be5437f42f76e8bd12b0280

Rippling Border Shader by https://www.reddit.com/user/Arnklit
https://www.reddit.com/r/godot/comments/l8hz6y/how_can_i_get_an_outline_shader_to_wobble/

Distortion (Vortex) Shader by https://godotshaders.com/author/9exa/
https://godotshaders.com/shader/vortex-overlay/

Palette-Cycling Earthbound Shader by https://godotshaders.com/author/r3tr0_dev/
https://godotshaders.com/shader/earthbound-like-battle-background-shader-w-scroll-effect-and-palette-cycling/
"""
###############################################################################


func _ready():
	# set up modifiable shader
	sprite_node.material.duplicate()
	# establish our area by sprite_size
	sprite_size = Vector2(\
	sprite_node.texture.get_width(),\
	sprite_node.texture.get_height())
	
	# reposition debug, set collision extents, and run _process func
	var center_position_with_offset = -sprite_size/4
	var half_sprite_total_area = (sprite_size.x+sprite_size.y)/4
	debug_underlay.rect_position = center_position_with_offset
	bubble_collision.shape.radius = half_sprite_total_area#-sprite_size.x/2
	
	# customise this node's effect group id
	time_bubble_group_id = time_bubble_group_id+str(self)
	
	# set up lifespan timer
	lifespan_timer.wait_time = ability_duration
	
	# begin animations
	tickEffect()
	bubble_pulse_animate_in()


func _process(_delta):
	if is_active:
		tickEffect()


###############################################################################


func _on_Area2D_body_entered(body):
	# validate whether the body entering is a valid target
	# can only affect non-player actors and non-player projectiles
	if not body is Player:
		apply_time_slow_effect(body, "actor")


func _on_Area2D_body_exited(body):
	# check if body is already time slowed
	if body.is_in_group(time_bubble_group_id):
		remove_time_slow_effect(body)


func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if area is Projectile:
		print("a")
		if not area.projectile_owner is Player:
			print("b")
			apply_time_slow_effect(area, "projectile")


func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	# validation incase the projectile is freed before this is called
	if area != null:
		if area.is_in_group(time_bubble_group_id):
			remove_time_slow_effect(area)



func _on_AnimationTween_tween_completed(_object, _key):
	
	# if first time running
	if not is_active:
		is_active = true
		lifespan_timer.start()
	
	# if last time running
	elif is_active:
		is_active = false
		self.visible = false
		get_tree().call_group(time_bubble_group_id, "remove_time_slow_effect")
		queue_free()


func _on_LifespanTimer_timeout():
	bubble_pulse_animate_out()


###############################################################################


func bubble_pulse_animate_in():
	var starting_scale = Vector2(0.05, 0.05)
	var ending_scale = Vector2(1.0, 1.0)
	
	anim_tween.interpolate_property(self, "scale", \
	starting_scale, ending_scale, \
	tween_anim_duration, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	anim_tween.start()
	self.visible = true


func bubble_pulse_animate_out():
	var starting_scale = Vector2(1.0, 1.0)
	var ending_scale = Vector2(0.05, 0.05)
	
	anim_tween.interpolate_property(self, "scale", \
	starting_scale, ending_scale, \
	tween_anim_duration, Tween.TRANS_BACK, Tween.EASE_IN)
	anim_tween.start()


func tickEffect():
	# rotate sprite whilst resetting shader
	sprite_node.rotation_degrees += 2
	sprite_node.material.set_shader_param("rel_rect_size", get_canvas_transform().get_scale()*sprite_size)


func apply_time_slow_effect(affected_target, target_type):
	if is_active:
		# instantiate new particle effect
		var time_slow_particles = load(GlobalReferences.time_slow_particles)
		var new_particles = time_slow_particles.instance()
		affected_target.add_child(new_particles)
		# handle particle application
		# check if signal exists (has target been affected before)
		# add it if not
		if not affected_target.has_signal("lost_time_slow"):
			affected_target.add_user_signal("lost_time_slow")
		# does queue_free disconnect this signal later?
		affected_target.connect("lost_time_slow", new_particles, "end_timeslow")
		
		# handle bubble management
		affected_target.add_to_group(time_bubble_group_id)
		
		#debugging
#		affected_target.visible = false


func remove_time_slow_effect(affected_target):
	if is_active:
		# emit signal to remove particles
		if affected_target.has_signal("lost_time_slow"):
			affected_target.emit_signal("lost_time_slow")

#		# debugging
#		affected_target.visible = true
		
#		# validate what type of node to remove time slow effect from
#		if body is Projectile:
#			if not body.projectile_owner is Player:
#				remove_time_slow_effect(body, "projectile")
#		if not body is Player:
#			remove_time_slow_effect(body, "actor")
