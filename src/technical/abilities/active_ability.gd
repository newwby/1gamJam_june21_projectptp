
class_name ActiveAbility
extends BaseAbility

var current_ability_loadout

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	#

# TODO add more weapon ability variations
# basic weapon ability 
func activate_ability():
	if GlobalDebug.player_active_ability_logs: print(name, " (ability) is activated!")
	if current_ability_loadout == GlobalVariables.AbilityTypes.BLINK:
		blink()


func set_new_ability(ability_id):
	current_ability_loadout = ability_id


# the blink dodge is an ability that lets a player avoid enemy fire
# and move with great speed in one direction for a brief duration
func blink():
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
