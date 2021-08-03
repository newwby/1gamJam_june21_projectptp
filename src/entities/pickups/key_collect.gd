extends Node2D

# note for future - a collectable scene to attach as a child to collectable
# objects would allow for quicker customisation of new collectable objs

export var key_active = true

onready var collectable_area = $Area2D/CollisionShape2D

onready var self_sprite = $Sprite
onready var shadow_sprite = $ShadowSprite
onready var hover_animation = $AnimationPlayer_Float

onready var ambient_particle_effect = $SpriteStarParticlesAmbient
onready var collection_particle_effect = $SpriteStarParticlesFlourish
onready var audio_collection_array = $PickupAudio


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_key_activity_state(key_active)


###############################################################################


func set_key_activity_state(is_active):
	if is_active:
		hover_animation.play("vibrating")
	else:
		hover_animation.stop()
		ambient_particle_effect.emitting = false
		ambient_particle_effect.visible = false
		shadow_sprite.visible = false
		collectable_area.set_deferred("disabled", true)


###############################################################################


func _on_Area2D_body_entered(body):
	if body is Player and key_active:
		key_is_collected()
		# show key on player, set key switch
		body.player_key_collectable_status(true)
		particle_flourish()
		audio_collection_array.call_audio_array()
		yield(audio_collection_array, "all_array_sounds_completed")
		delete_self()


###############################################################################


# set key as collected
func key_is_collected():
	key_active = false
	collectable_area.set_deferred("disabled", true)
	self_sprite.visible = false
	shadow_sprite.visible = false
	hover_animation.stop()


# delete self with particle effect flourish (amount+, gravity invert)
func particle_flourish():
	ambient_particle_effect.emitting = false
	collection_particle_effect.emitting = true


func delete_self():
	print("key is free")
	call_deferred("queue_free")


###############################################################################
