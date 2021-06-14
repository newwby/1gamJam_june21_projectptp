extends Node2D

# must have had a child previously for zero children to be a
# valid deletion condition
var has_had_children = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_state_for_deletion()

func check_state_for_deletion():
	if self.get_child_count() == 0 and has_had_children:
		queue_free()
	elif self.get_child_count() > 0:
		has_had_children = true
	print(get_child_count())
