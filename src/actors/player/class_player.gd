
class_name Player
extends Actor

var last_facing_not_firing: Vector2 = Vector2.ZERO

# player sprite is automatically resized according to this value
var sprite_intended_size = 100

# determine whether the player is firing
var is_firing = false

# how fast does the orbital rotation node rotate
var orbiting_rotation_rate = 3

# where is the player aiming
var current_mouse_position: Vector2 = Vector2.ZERO
# direction the palyer is currently aiming
var current_mouse_target: Vector2 = Vector2.ZERO
# direction was the player aiming when they first started holding attack
var firing_target: Vector2 = Vector2.ZERO

onready var player_sprite = $SpriteHolder/StaticSprite
onready var sprite_animation_tween = $SpriteHolder/StaticSprite/RockingTween

onready var weapon_ability_node = $AbilityHolder/WeaponAbility
onready var active_ability_node_1 = $AbilityHolder/ActiveAbility1
onready var active_ability_node_2 = $AbilityHolder/ActiveAbility2

onready var target_sprite_rotator = $TargetingSpriteHolder
onready var orbit_handler_node = $OrbitalProjectileHolder

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# adjust the player sprite according to (var sprite_intended_size)
	setup_sprite_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_attack_input()
	_process_orbit_handler_rotate(delta)
	_process_rotate_targeting_sprite(delta)


# for orbital and radar projectiles
func _process_orbit_handler_rotate(_dt):
	orbit_handler_node.rotation_degrees += orbiting_rotation_rate


# working on
func _process_rotate_targeting_sprite(_dt):
#	var directional_vector = get_global_mouse_position() - position
#	var point_angle = directional_vector.angle()
#	target_sprite_rotator.rotation = (point_angle+90)
	target_sprite_rotator.look_at(get_global_mouse_position())
#	target_sprite_rotator.look_at(get_local_mouse_position())
	target_sprite_rotator.rotation_degrees += 90
	
	#target_sprite_rotator.rotation
#
#	var offset = -PI * 0.5
##	var screen_pos = get_viewport().get_camera()(self.global_transform.origin)
##Call get_viewport().get_mouse_position() for global position and subtract the node position to get the local mouse position.
#
#	var mouse_pos = get_viewport().get_mouse_position()
#	var vector_to = mouse_pos - position
#
#	target_sprite_rotator.rotation = angle


# track any mouse movement as new co-ordinates for mouse position
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		current_mouse_position = event.position


###############################################################################


# player class override for handling movement, with key input
func process_handle_movement(_dt):
	velocity = Vector2(0,0)
	velocity = get_movement_input() * movement_speed
	var _collided_with = move_and_slide(velocity)


###############################################################################


# player sprite is scaled according to its own dimensions and the
# intended sprite size, adjusting scale by proportions
func setup_sprite_scale():
	var get_sprite_dimensions = player_sprite.get_rect().size
		# calculate if the dimensions of the sprite are the same length or not
	# needing to know the exact difference is now defunct
	# all references to dimension_diff commented out
	#var dimension_diff
	var shorter_dimension
	if get_sprite_dimensions.x > get_sprite_dimensions.y:
		#dimension_diff = get_sprite_dimensions.x-get_sprite_dimensions.y
		shorter_dimension = get_sprite_dimensions.y
	elif get_sprite_dimensions.y > get_sprite_dimensions.x:
		#dimension_diff = get_sprite_dimensions.y-get_sprite_dimensions.x
		shorter_dimension = get_sprite_dimensions.x
	else:
		#dimension_diff = 0
		shorter_dimension = get_sprite_dimensions.x
	
	# apply the scale adjustment
	var sprite_scale_adj = sprite_intended_size/shorter_dimension
	player_sprite.scale = Vector2(sprite_scale_adj,sprite_scale_adj)


###############################################################################


# take movement input from the player
# calculate input direction accordingly
func get_movement_input():
	var input_direction = Vector2(0,0)
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	
	# save last direction moved for purposes of facing
	if input_direction != Vector2(0,0):
		last_facing = input_direction
		is_moving = true
	else:
		is_moving = false
	
	return input_direction.normalized()


# when fire button is pressed we store firing velocity
# when fire button is released we are allowed to store a new firing velocity
# hold button to fire
func get_attack_input():
	if Input.is_action_pressed("fire_weapon"):
		current_mouse_target = -(self.position - get_global_mouse_position())
		if not is_firing:
			is_firing = true
			firing_target = current_mouse_target
		weapon_ability_node.attempt_ability()
	elif not Input.is_action_pressed("fire_weapon"):
		if is_firing:
			is_firing = false


###############################################################################
