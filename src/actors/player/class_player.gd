
class_name Player
extends Actor

var last_facing_not_firing: Vector2 = Vector2.ZERO

# player sprite is automatically resized according to this value
var sprite_intended_size = 100

# determine whether the player is firing
var is_firing = false

var current_mouse_position: Vector2 = Vector2.ZERO
var firing_target: Vector2 = Vector2.ZERO

onready var player_sprite = $SpriteHolder/StaticSprite
onready var sprite_animation_tween = $SpriteHolder/StaticSprite/RockingTween

onready var weapon_ability_node = $AbilityHolder/WeaponAbility
onready var active_ability_node_1 = $AbilityHolder/ActiveAbility1
onready var active_ability_node_2 = $AbilityHolder/ActiveAbility2

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# adjust the player sprite according to (var sprite_intended_size)
	setup_sprite_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	get_attack_input()


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
	
	return input_direction.normalized()


# when fire button is pressed we store firing velocity
# when fire button is released we are allowed to store a new firing velocity
# hold button to fire
func get_attack_input():
	if Input.is_action_pressed("fire_weapon"):
		if not is_firing:
			is_firing = true
			firing_target = -(self.position - get_global_mouse_position())
		weapon_ability_node.attempt_ability()
	elif not Input.is_action_pressed("fire_weapon"):
		if is_firing:
			is_firing = false


###############################################################################
