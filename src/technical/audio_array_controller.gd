
class_name AudioArrayController, "res://art/icons/kenney_emotespack/PNG/Vector/Style 1/emote_music.png"
extends Node2D

const TESTING_MODE = false

# no implementation of the following blocks/functions yet

# don't run the audio array
export var is_enabled = true
# how many times to run the audio array
export var play_iterations = 1
# if iterating, will it pause between iterations?
export var wait_between_iterations = 0.2
# can subsequent iterations play the same sound? true = always different
# will stop if set to true and runs out of unique sounds to play
export var iteratives_are_unique = true
# if this bool is set to true, ALL additional functions below are skipped
# that includes play entropy, randomisation, and overrides
export var basic_mode_only = true

# following vars control whether the effect plays or not
# for handling entropy (skip if reaching this, reset on skip)
export var max_call_entropy_limit = 0
export var min_call_entropy_limit = 0
# for handling random playback failure/skip
export var playback_chance = 1.0
# chance to skip on reaching minimum entropy
export var entropy_play_chance_at_min = 0
# does an entropy fail stop all playing, or just the current iteration?
export var entropy_halt_iterations = true

# following vars control the settings of the played sound effect
# for pitch
# base-random to base+random range of volume db shift
export var pitch_randomness_modifier = 0.05
# no pitch randomisation if this isn't set
export var pitch_is_randomised = false
# is the base set pitch of the played sound effect changed to a new value?
export var pitch_base_is_overridden = false
# if above is true, change to this value
export var pitch_override = 0.0
# variables below are for similar but for volume-db
# for volume db
# base-random to base+random range of volume db shift
export var volume_db_randomness_modifier = 5
# no volume db randomisation if this isn't set
export var volume_db_is_randomised = false
# is the base set volume db of the played sound effect changed to a new value?
export var volume_db_base_is_overridden = false
# if above is true, change to this value
export var volume_db_override = 0

# calculated by distance between call_entropy_limit min and max
# as a function of entropy_play_chance_at_min to 100% chance at max
var entropy_accrued_per_step_play_chance = 0

# timer node
onready var iteration_timer = $IterationPauseTimer


##############################################################################
	
#fortesting only
func _ready():
	set_iteration_timer()
	#DEBUG_AUTOPLAY
	if TESTING_MODE:
		call_audio_array()


##############################################################################


func set_iteration_timer():
	iteration_timer.wait_time = wait_between_iterations


##############################################################################


# get all audiostreamplayer2d children, to pass to 'shuffle_audio_and_play()'
func call_audio_array():
	if is_enabled:
		# populate a valid array of sound effects
		var full_audio_array = []
		for audio_slave in self.get_children():
			if audio_slave is AudioStreamPlayer2D:
				full_audio_array.append(audio_slave)
			
			# this block for testing only, functions fine if commented out
			if audio_slave is Node and TESTING_MODE:
				for audio_slave_debug in audio_slave.get_children():
					if audio_slave_debug is AudioStreamPlayer2D:
						full_audio_array.append(audio_slave_debug)
		
		if full_audio_array.size() > 0:
			shuffle_audio_and_play(full_audio_array, play_iterations)

# HAVE NOT IMPLEMENTED UNIQUE ITERATIVE CONTROL/CHECKS
#export var is_enabled = true
## how many times to run the audio array
#export var play_iterations = 1
## can subsequent iterations play the same sound? true = always different
## will stop if set to true and runs out of unique sounds to play
#export var iteratives_are_unique = true


# play a random sound effect from a list/array of sound effects
func shuffle_audio_and_play(given_audio_array: Array, remaining_iterations: int):
	
	if GlobalDebug.audio_array_controller_logs: print("\n", self, "(", self.name, ") is beggining shuffle")
	# get array size
	var upper_limit = given_audio_array.size()
	# get random effect from array
	var random_sound = GlobalFuncs.ReturnRandomRange(0, upper_limit)
	var chosen_sound = given_audio_array[random_sound]
	if GlobalDebug.audio_array_controller_logs: print("chosen sound is ", chosen_sound)
	
	# make sure is valid sound effect to play
	if chosen_sound is AudioStreamPlayer2D:
		# basic mode ignore all overrides and randomisation
		if basic_mode_only:
			chosen_sound.play()
		# if no basic mode, use an advanced play function
		# advanced play function processes entropy, override, and randomisation
		else:
			if GlobalDebug.audio_array_controller_logs: print("chosen sound ", chosen_sound, " playing")
			# this goes into function
			if GlobalDebug.audio_array_controller_logs: print("set funcstateobj")
			var func_play_chosen = play_chosen_sound(chosen_sound)
			if GlobalDebug.audio_array_controller_logs: print("returned to shuffle_audio_func")
			# does the array carry on
			if remaining_iterations-1 > 0:
				if GlobalDebug.audio_array_controller_logs: print("trying to remove sound ", chosen_sound, " from array ", given_audio_array)
#				given_audio_array.remove(chosen_sound)
				if GlobalDebug.audio_array_controller_logs: print("\nstarting iteration timer")
				iteration_timer.start()
				yield(iteration_timer, "timeout")
				if GlobalDebug.audio_array_controller_logs: print("iteration timer expired")
				if GlobalDebug.audio_array_controller_logs: print("starting new iterative shuffle")
				shuffle_audio_and_play(given_audio_array, remaining_iterations-1)
			else:
				if GlobalDebug.audio_array_controller_logs: print("\nend of iterations")
			if GlobalDebug.audio_array_controller_logs: print("finishing yielded chosen_sound func")
#			func_play_chosen.resume()


# function for applying modifiers to audio parameters then playing sound
func play_chosen_sound(given_sound):
	# before doing anything, need to store volume_db and pitch_scale values
	var pitch_scale_original_value = given_sound.pitch_scale
	var volume_db_original_value = given_sound.volume_db
	
	# branches for pitch
	# if override value is set, replace the audio node pitch scale value
	if pitch_base_is_overridden:
		given_sound.pitch_scale = pitch_override
	
	if pitch_is_randomised:
	# call for applying a randomisation value to the sound pitch
		randomise_pitch(given_sound, given_sound.pitch_scale)
	
	# branches for volume_db
	# if override value is set, replace the audio node volume db value
	if volume_db_base_is_overridden:
		given_sound.volume_db = volume_db_override
	
	# call for applying a randomisation value to the sound volume db
	if volume_db_is_randomised:
		randomise_volume_db(given_sound, given_sound.volume_db)
	
	given_sound.play()
	# reset values if they were changed
	if GlobalDebug.audio_array_controller_logs: print("wait for sound, ", given_sound, " to finish")
	yield(given_sound, "finished")
	if pitch_base_is_overridden or pitch_is_randomised:
		if GlobalDebug.audio_array_controller_logs: print( "pitch scale currently at ", given_sound.pitch_scale)
		if GlobalDebug.audio_array_controller_logs: print("restoring original pitch scale of ", pitch_scale_original_value)
		if GlobalDebug.audio_array_controller_logs: print( "pitch scale now at ", given_sound.pitch_scale)
		given_sound.pitch_scale = pitch_scale_original_value
	
	if volume_db_base_is_overridden or volume_db_is_randomised:
		if GlobalDebug.audio_array_controller_logs: print( "volume db currently at ", given_sound.volume_db)
		if GlobalDebug.audio_array_controller_logs: print("restoring original volume db of ", volume_db_original_value)
		if GlobalDebug.audio_array_controller_logs: print( "volume db now at ", given_sound.volume_db)
		given_sound.volume_db = volume_db_original_value
	if GlobalDebug.audio_array_controller_logs: print("return to shuffle_audio_func")
	yield()
	if GlobalDebug.audio_array_controller_logs: print("chosen_sound func resumed and concluded")

##############################################################################


# not currently implemented
#func check_entropy():
#	pass


## calculated by distance between call_entropy_limit min and max
## as a function of entropy_play_chance_at_min to 100% chance at max
#var entropy_accrued_per_step_play_chance = 0

## following vars control whether the effect plays or not
## for handling entropy (skip if reaching this, reset on skip)
#export var max_call_entropy_limit = 0
#export var min_call_entropy_limit = 0
## for handling random playback failure/skip
#export var playback_chance = 1.0
## chance to skip on reaching minimum entropy
#export var entropy_play_chance_at_min = 0
## does an entropy fail stop all playing, or just the current iteration?
#export var entropy_halt_iterations = true


##############################################################################


func randomise_pitch(given_sound, base_value):
	var base_pitch = base_value
	
	if GlobalDebug.audio_array_controller_logs: print(given_sound, " base_pitch: ", base_pitch)
	# generate a random value from the base and modifier
	var random_pitch =\
	randomise_audio_parameter(base_pitch, pitch_randomness_modifier)
	if GlobalDebug.audio_array_controller_logs: print("applying pitch_randomness_modifier of ", pitch_randomness_modifier)
	if GlobalDebug.audio_array_controller_logs: print(given_sound, " random_pitch: ", random_pitch)
	# set the returned value
	given_sound.pitch_scale = random_pitch


func randomise_volume_db(given_sound, base_value):
	# if no override, grab the current value for calculations
	var base_volume_db = base_value
	if GlobalDebug.audio_array_controller_logs: print(given_sound, " base_volume_db: ", base_volume_db)
	# generate a random value from the base and modifier
	var random_volume_db =\
	randomise_audio_parameter(base_volume_db, volume_db_randomness_modifier)
	if GlobalDebug.audio_array_controller_logs: print("applying volume_db_randomness_modifier of ", volume_db_randomness_modifier)
	if GlobalDebug.audio_array_controller_logs: print(given_sound, " random_volume_db: ", random_volume_db)
	# set the returned value
	given_sound.volume_db = random_volume_db


# for randomising volume_db or pitch if necessary
func randomise_audio_parameter(base_value, randomness_modifier):
	# the rand_range func generates a value between these two
	var range_min = base_value - randomness_modifier
	var range_max = base_value + randomness_modifier
	# generate value to return
	var random_adjustment = GlobalFuncs.ReturnRandomRange(\
	range_min, range_max)
	return random_adjustment


#export var pitch_randomness_modifier = 0.05
#export var volume_db_randomness_modifier = 5
#export var array_pitch_override = false
#export var pitch_override = 0
#export var array_volume_db_override = false
#export var volume_db_override = 0


## following vars control the settings of the played sound effect
## base-random to base+random range of volume db shift
#export var pitch_randomness_modifier = 0.05
## base-random to base+random range of volume db shift
#export var volume_db_randomness_modifier = 5
## is the base set pitch of the played sound effect changed to a new value?
#export var array_pitch_override = false
## if above is true, change to this value

#export var pitch_override = 0
## is the base set volume db of the played sound effect changed to a new value?
#export var array_volume_db_override = false
## if above is true, change to this value
#export var volume_db_override = 0
