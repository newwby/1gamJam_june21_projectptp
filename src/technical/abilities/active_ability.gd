
class_name ActiveAbility
extends BaseAbility

var current_ability_loadout

# reference a string path held elsewhere (for simpler path changes)
const MODIFIER_TIME_SLOW_PATH = GlobalReferences.modifier_time_slow
# resource path of the projectile actors can spawn
onready var modifier_time_slow_object = preload(MODIFIER_TIME_SLOW_PATH)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


# active ability
func activate_ability():
	if GlobalDebug.player_active_ability_logs: print(name, " (ability) is activated!")
	if current_ability_loadout == GlobalVariables.AbilityTypes.BLINK:
		call_ability_blink()
	if current_ability_loadout == GlobalVariables.AbilityTypes.TIME_SLOW:
		call_ability_time_slow()


###############################################################################


func set_new_ability(ability_id):
	current_ability_loadout = ability_id


###############################################################################


# the blink dodge is an ability that lets a player avoid enemy fire
# and move with great speed in one direction for a brief duration
func call_ability_blink():
	# get the heading we're going to blink toward
	var new_velocity =\
	 get_global_mouse_position() - owner.position
	
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
		owner.position += (new_velocity * 0.075)
		# start the timer
		blink_timer.start()
		# wait until it is finished
		yield(blink_timer, "timeout")
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
	# call actor speed func on all actors active
	# TODO exclude actor who called this ability
	var group_to_call = get_tree().get_nodes_in_group("actors")
	# call	
	for actor in group_to_call:
		time_slow_actor_speed(actor)

	# call projectile speed func on all projectiles active
	group_to_call = get_tree().get_nodes_in_group("projectiles")
	for projectile in group_to_call:
		time_slow_projectile_speed(projectile)
	# TODO handle newly created things between start and expiry


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
