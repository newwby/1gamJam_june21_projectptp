
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
var activation_cooldown = 0.2 setget set_activation_cooldown
# presence of  cooldown timer must be checked before it can be called by methods
var is_timer_setup = false
# reference to timer node that controls activation and cooldown
var activation_timer: Timer
# bool to indicate whether the ability can be activated or not

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	set_cooldown_timer()


##############################################################################


# iniitalises and resets the wait time on the activation timer
func set_cooldown_timer():
	
	# check timer is valid
	# if it is valid, run function
	# else debug print
	if $ActivationCooldown != null:
		activation_timer = $ActivationCooldown
		set_activation_cooldown(activation_cooldown)
		is_timer_setup = true
	else:
		if GlobalDebug.validate_node_existence: print("ActivationTimer for WeaponAbility "+ self.name + " not found")


func set_activation_cooldown(value):
	activation_cooldown = value
	if activation_timer != null:
		if activation_cooldown <= 0:
			activation_cooldown = 0.1
		activation_timer.wait_time = activation_cooldown
		activation_timer.start()


##############################################################################


# check if the ability is valid
func attempt_ability():
	if GlobalDebug.ability_cooldown_not_met_logging: print("checking validty of ability ", self.name)
	# if activation timer isn't set up, ability can't be activated
	
	# make sure timer exists
	if is_timer_setup:
		# check if ability on cooldown or not by whether the timer is running
		is_ability_on_cooldown = !activation_timer.is_stopped()
		if GlobalDebug.ability_cooldown_not_met_logging: print(self.name, " on cooldown? ", is_ability_on_cooldown)
		# activate ability if not on cooldown
		if not is_ability_on_cooldown:
			# and start timer for new cooldown
			if activation_timer.is_stopped():
				activation_timer.start()
			activate_ability()


# this function is just a placeholder
# individual child ability classes will define this function
func activate_ability():
	if GlobalDebug.ability_cooldown_not_met_logging: print("attempting to activate ability ", self.name)

