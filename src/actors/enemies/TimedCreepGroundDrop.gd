extends Timer

var enemy_owner
var is_active = false


###############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	if set_owner_if_enemy():
		is_active = true


###############################################################################


func set_owner_if_enemy():
	enemy_owner = get_parent()
	if enemy_owner is Enemy:
		return true


###############################################################################


func _on_TimedCreepGroundDrop_timeout():
	if is_active:
		create_new_creep()
#		if enemy_owner.is_moving:
#			create_new_creep()

###############################################################################

func create_new_creep():
	# creep effect has enemy owner
	if is_active:
		var creep_effect_scene = load(GlobalReferences.creep_ground)
		var new_creep = creep_effect_scene.instance()
		new_creep.creep_owner = enemy_owner
		new_creep.position = enemy_owner.position
		get_tree().get_root().add_child(new_creep)
