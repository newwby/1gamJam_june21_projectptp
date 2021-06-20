
class_name State_Scanning, "res://art/shrek_pup_eye_sprite.png"
extends State

signal found_target(new_target)

###############################################################################


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


###############################################################################


# must be passed a range group of nodes
func scan_for_player(given_range_group):
# pass a range group to this function
# function looks for a player in said group, finds the closest player
# returns the closest player,
# so call this on var current_target in enemy scene
# returns null if can't be found (check if returns null and ignore)
		var new_target = get_nearest_player_in_range_group(given_range_group)
		emit_signal("found_target", new_target)

