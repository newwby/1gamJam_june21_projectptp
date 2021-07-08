
class_name ActiveModifier
extends Node2D

signal effect_applied
signal effect_removed

var expiry_time = 10.0

onready var modifier_expiry_timer = $ExpiryTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	# set the duration before effect is removed
	modifier_expiry_timer.wait_time = expiry_time
	# apply the modifier
	apply_effect()
	# wait until effect is in action before starting expiry timer
	yield(self, "effect_applied")
	# start the countdown to effect removal
	modifier_expiry_timer.start()


###############################################################################


func _on_ExpiryTimer_timeout():
	if GlobalDebug.log_parent_modifier_steps: print("_on_ExpiryTimer_timeout")
	# remove effect before deleting self
	remove_effect()
	# make sure we wait until effect is removed
	yield(self, "effect_removed")
	# delete self
	queue_free()


###############################################################################


func apply_effect():
	if GlobalDebug.log_parent_modifier_steps: print("apply_effect")
	# announce we're done
	emit_signal("effect_applied")


func remove_effect():
	if GlobalDebug.log_parent_modifier_steps: print("remove_effect")
	# announce we're done
	emit_signal("effect_removed")
