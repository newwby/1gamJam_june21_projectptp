
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


func blink():
	var new_velocity = owner.last_facing
	
	# disable collision with everything except walls/obstacles
	owner.set_collision_mask_bit(2, false)
	owner.set_collision_mask_bit(3, false)
	owner.set_collision_mask_bit(5, false)
	owner.set_collision_mask_bit(7, false)
	
	var blink_timer = Timer.new()
	self.add_child(blink_timer)
	blink_timer.wait_time = 0.01
	blink_timer.autostart = false
	blink_timer.one_shot = true
	
	owner.is_damageable_by_foes = false
	
	var loop_count = 12
	var current_loop = 0
	while current_loop < loop_count:
		owner.visible = !owner.visible
		owner.position += (new_velocity * 25)
		blink_timer.start()
		yield(blink_timer, "timeout")
		current_loop += 1
	
	# TODO fix this it does not work
	# reenable collision with everything except walls/obstacles
	owner.set_collision_mask_bit(2, true)
	owner.set_collision_mask_bit(3, true)
	owner.set_collision_mask_bit(5, true)
	owner.set_collision_mask_bit(7, true)

	owner.is_damageable_by_foes = true
	owner.visible = true
	self.remove_child(blink_timer)
	blink_timer.queue_free()
