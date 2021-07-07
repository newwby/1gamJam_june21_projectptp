extends Node2D

# this is the temporary faux-json for data storage on weapon behaviours
var weapon = preload("res://src/technical/abilities/json_weapon_styles.gd")

signal collected

export(int) var weapon_style_index

var weapon_style_key
var chosen_weapon_style
var sprite_path
var sprite_scale_bound = 0.125
var is_collected = false
var is_setup = false

onready var pickup_graphic = $Sprite
onready var pickup_shadow = $Sprite/ShadowSprite

#######################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_collectable()


#######################################################################


func setup_collectable():
	if not is_setup and not is_collected:
		set_by_key()
		set_pickup_sprite()
		set_sprite()
		is_setup = true


func set_by_key():
	if weapon.Style.keys()[weapon_style_index] != null:
		match weapon_style_index:
			0:
				chosen_weapon_style = weapon.Style.SPLIT_SHOT
			1:
				chosen_weapon_style = weapon.Style.TRIPLE_BURST_SHOT
			2:
				chosen_weapon_style = weapon.Style.SNIPER_SHOT
			3:
				chosen_weapon_style = weapon.Style.RAPID_SHOT
			4:
				chosen_weapon_style = weapon.Style.HEAVY_SHOT
			5:
				chosen_weapon_style = weapon.Style.VORTEX_SHOT
			6:
				chosen_weapon_style = weapon.Style.WIND_SCYTHE
			7:
				chosen_weapon_style = weapon.Style.BOLT_LANCE


# 
func set_pickup_sprite():
	var weapon_type = weapon.STYLE_DATA[chosen_weapon_style]
	sprite_path = weapon_type[weapon.DataType.WEAPON_ICON_SPRITE]


func set_sprite():
	pickup_graphic.texture = load(sprite_path)
	pickup_shadow.texture = load(sprite_path)
	pickup_graphic.scale = Vector2(sprite_scale_bound, sprite_scale_bound)


#######################################################################

func _on_Area_body_entered(body):
	if not is_collected and body is Player:
		# checks if player is blink dashing
		if body.is_damageable_by_foes:
			body.weapon_ability_node.set_new_weapon(chosen_weapon_style)
			body.weapon_ability_node.set_new_cooldown_timer()
			emit_signal("collected")


func _on_NewWeaponPickup_collected():
	if not is_collected:
		is_collected = true
		pickup_graphic.visible = false
		queue_free()

#######################################################################

# not really a powerup
func activate_powerup():
	pass
	
	#######################################################################
