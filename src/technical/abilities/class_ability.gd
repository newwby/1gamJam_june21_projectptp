
class_name BaseAbility
extends Node2D

# if false disable this ability from functioning entirely
# this is DIFFERENT to a cooldown
var is_ability_enabled: bool = true

# range in pixels for ai patterns utilising this ability to consider it valid
var ai_minimum_range_for_use: float
var ai_maximum_range_for_use: float

# if true ability cannot activate  but is still allowed (unless false above)
var is_ability_on_cooldown: bool = false
# determines the length of the cooldown/activation timer wait_time
var activation_cooldown = 0.2
# presence of  cooldown timer must be checked before it can be called by methods
var is_timer_setup = false
# reference to timer node that controls activation and cooldown
var activation_timer: Timer


##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_cooldown_timer()


##############################################################################


# iniitalises and resets the wait time on the activation timer
func setup_cooldown_timer():
	
	# check timer is valid
	# if it is valid, run function
	# else debug print
	if $ActivationCooldown != null:
		activation_timer = $ActivationCooldown
		if activation_cooldown <= 0:
			activation_cooldown = 0.1
		activation_timer.wait_time = activation_cooldown
		activation_timer.start()
		is_timer_setup = true
	else:
		if GlobalDebug.validate_node_existence: print("ActivationTimer for WeaponAbility "+ self.name + " not found")


##############################################################################


# check if the ability is valid
func attempt_ability():
	if GlobalDebug.ability_cooldown_not_met_logging: print("attempting to activate ability ", self.name)
	# if activation timer isn't set up, ability can't be activated
	if is_timer_setup:
		# check if timer is running
		if activation_timer.is_stopped():
			# if it isn't, run ability
			if GlobalDebug.ability_cooldown_not_met_logging: print("ability ", self.name, "activated!")
			activate_ability()
			activation_timer.start()
		else:
			if GlobalDebug.ability_cooldown_not_met_logging: print("ability ", self.name, " on cooldown!")
#		.
		pass


# this function is just a placeholder
# individual child ability classes will define this function
func activate_ability():
	pass

