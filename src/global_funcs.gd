extends Node

func ReturnRandomRange(value_floor: float, value_ceiling: float):
	randomize()
	return rand_range(value_floor, value_ceiling)

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

# decorator yield func code dump
#
#func run_yielded_function():
#	print("start run_yielded_function()") #1
#	print("var yielded_function = foo()") #2
#	var yielded_function = foo() #2
#	print("yielded_function.resume()") #5
#	yielded_function.resume() #5
#	print("end run_yielded_function()") #7
#
#func foo():
#	print("start foo()") #3
#	print("yield") #4
#	yield() #4
#	print("end foo()") #6
