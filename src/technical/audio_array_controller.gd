
class_name AudioArrayController, "res://art/icons/kenney_emotespack/PNG/Vector/Style 1/emote_music.png"
extends Node2D

# no implementation of the following blocks/functions yet

# don't run the audio array
export var is_enabled = true
# how many times to run the audio array
export var play_iterations = 1

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
# base-random to base+random range of volume db shift
export var pitch_randomness_modifier = 0.05
# base-random to base+random range of volume db shift
export var volume_db_randomness_modifier = 5
# is the base set pitch of the played sound effect changed to a new value?
export var array_pitch_override = false
# if above is true, change to this value
export var pitch_override = 0
# is the base set volume db of the played sound effect changed to a new value?
export var array_volume_db_override = false
# if above is true, change to this value
export var volume_db_override = 0

# calculated by distance between call_entropy_limit min and max
# as a function of entropy_play_chance_at_min to 100% chance at max
var entropy_accrued_per_step_play_chance = 0


##############################################################################


# get all audiostreamplayer2d children, to pass to 'shuffle_audio_and_play()'
func call_audio_array():
	if is_enabled:
		var audio_array_as_children = []
		for audio_slave in self.get_children():
			if audio_slave is AudioStreamPlayer2D:
				audio_array_as_children.append(audio_slave)
		if audio_array_as_children.size() > 0:
			shuffle_audio_and_play(audio_array_as_children)


# play a random sound effect from a list/array of sound effects
func shuffle_audio_and_play(audio_array: Array):
	# get array size
	var upper_limit = audio_array.size()
	# get random effect from array
	var random_sound = GlobalFuncs.ReturnRandomRange(0, upper_limit)
	var chosen_sound = audio_array[random_sound]
	# make sure is valid sound effect
	if chosen_sound is AudioStreamPlayer2D:
		chosen_sound.play()
