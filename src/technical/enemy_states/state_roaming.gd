
class_name State_Roaming, "res://art/shrek_pup_eye_sprite.png"
extends State

var wander_to_position
var wandering_distance_minimum
var wandering_distance_maximum
var wandering_timer_minimum
var wandering_timer_maximum
var distance_to_wandering_position_to_complete

# position relevant to $StateHandler/State_Roaming
onready var wandering_timer = $RoamingRepeatTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


#	elif current_target == null\
#	 and target_last_known_location == null\
#	 and is_active\
#	 and current_state != State.WANDER:
#		set_new_state(State.WANDER)



func check_if_near_wandering_position():
	if position.distance_to(wander_to_position) <\
	 distance_to_wandering_position_to_complete:
		return true
	else:
		return false


func start_and_randomise_wandering_timer():
#	wandering_timer.wait_time = random_value
	pass


# WANDERING STATE
# get random location nearby and move there
func state_wandering_move_to_random_nearby_location():
	# TODO move variablse out of this scope
	# TODO if within variable range
		# randomise within range then start wander pause timer
#	# if wander pause timer running no more wandering
#	var wander_to_position
#	var wandering_distance_minimum
#	var wandering_distance_maximum
#	var wandering_timer_minimum
#	var wandering_timer_maximum
#	var distance_to_wandering_position_to_complete
#
#	var wandering_timer = Timer.new()
	
	# if wandering position set, wander until close
	if wander_to_position != null:
		if check_if_near_wandering_position():
			wander_to_position = null
			start_and_randomise_wandering_timer()
	
	# check if no current wandering but can start
	elif wandering_timer.is_stopped() and\
	 wander_to_position == null:
		# set a new wandering position
		wander_to_position = get_nearby_location(\
		GlobalFuncs.ReturnRandomRange(\
		wandering_distance_minimum, wandering_distance_maximum))
