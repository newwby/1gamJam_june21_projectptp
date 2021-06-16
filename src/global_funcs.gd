extends Node

func ReturnRandomRange(value_floor: float, value_ceiling: float):
	randomize()
	return rand_range(value_floor, value_ceiling)

###############################################################################
