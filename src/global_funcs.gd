extends Node

func ReturnRandomRange(value_floor: float, value_ceiling: float):
	randomize()
	return rand_range(value_floor, value_ceiling)

# TODO search up all OUT-OF-SCOPE references
# OUT-OF-SCOPE make audio controller for handling audio nodes

# play a random sound effect from a list/array of sound effects
func shuffle_audio_and_play(audio_array: Array):
	# get array size
	var upper_limit = audio_array.size()
	# get random effect from array
	var random_sound = ReturnRandomRange(0, upper_limit)
	var chosen_sound = audio_array[random_sound]
	# make sure is valid sound effect
	if chosen_sound is AudioStreamPlayer2D:
		chosen_sound.play()

###############################################################################
