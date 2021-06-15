
class_name ModifierTimeSlow
extends ActiveModifier

# the modifier duration before expiry
const TIME_SLOW_DURATION = 2.0

###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# set new value for expiry time
	set_expiry_time_value()
	._ready()


###############################################################################


func apply_effect():
	print("ts added to ", self.name)
	.apply_effect()
#	get_tree().call_group("actors", set_actor_move_speed_slowed())
#	get_tree().call_group("projectiles", set_projectile_flight_speed_slowed())
#	get_tree().call_group("projectiles", set_projectile_rotator_orbit_speed_slowed())

func remove_effect():
	print("ts removed from ", self.name)
	.remove_effect()
#	get_tree().call_group("actors", set_actor_move_speed_normal())
#	get_tree().call_group("projectiles", set_projectile_flight_speed_normal())
#	get_tree().call_group("projectiles", set_projectile_rotator_orbit_speed_normal())


###############################################################################


func set_expiry_time_value():
	expiry_time = TIME_SLOW_DURATION


func set_actor_move_speed_slowed():
	if GlobalDebug.log_time_slow_modifier_steps: print("set_actor_move_speed_slowed", " on ", self.name)


func set_actor_move_speed_normal():
	if GlobalDebug.log_time_slow_modifier_steps: print("set_actor_move_speed_normal", " on ", self.name)


func set_projectile_flight_speed_slowed():
	if GlobalDebug.log_time_slow_modifier_steps: print("set_projectile_flight_speed_slowed", " on ", self.name)


func set_projectile_flight_speed_normal():
	if GlobalDebug.log_time_slow_modifier_steps: print("set_projectile_flight_speed_normal", " on ", self.name)


func set_projectile_rotator_orbit_speed_slowed():
	if GlobalDebug.log_time_slow_modifier_steps: print("set_projectile_rotator_orbit_speed_slowed", " on ", self.name)


func set_projectile_rotator_orbit_speed_normal():
	if GlobalDebug.log_time_slow_modifier_steps: print("set_projectile_rotator_orbit_speed_normal", " on ", self.name)
