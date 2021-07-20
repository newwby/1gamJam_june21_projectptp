extends Node2D

var sprite_size

onready var debug_underlay = $DebuggingRect
onready var sprite_node = $DistortionSprite
onready var bubble_collision = $Area2D/CollisionShape2D
#
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
	tickEffect()


func _process(_delta):
	tickEffect()


###############################################################################

func tickEffect():
	# rotate sprite whilst resetting shader
	sprite_node.rotation_degrees += 2
	sprite_node.material.set_shader_param("rel_rect_size", get_canvas_transform().get_scale()*sprite_size)
