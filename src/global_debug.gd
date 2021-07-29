extends Node

# console logging for node validation
var validate_node_existence = true

const DEBUG_BUTTON_ENABLED = false

# sound control settings for in-editor, out of gameplay
const MUSIC_ENABLED = false
const PLAYER_SE_ENABLED = false
const ENEMY_SE_ENABLED = false

# console logging for other debug purposes (print commands)
# debug for the rocking tween starting and stopping
var player_rocking_anim_tween = false
# debug for whether the projectile sprites beneath handler are being set
var proj_sprite_handling = false
# debug for ability unable to fire when activated console logging
var ability_cooldown_not_met_logging = false
# debug for projectile logging to console all exit behaviours
var projectile_exit_logging = false
# debug for spread projectile pattern spawning
var projectile_spread_pattern = false
# debug for the vibrating tween starting and stopping
var player_vibrating_anim_tween = false
# debug for if initial velocity hasn't been set correctly
var weapon_initial_velocity_check = false
# debugging for player active abilities
var player_active_ability_logs = false
# debugging for projectile spawning via console logging
var log_projectile_spawn_steps = false
# modifier superclass step logging to console
var log_parent_modifier_steps = false
# modifier for time slow step logging to console
var log_time_slow_modifier_steps = false
# console logging for enemy detection radii
var enemy_detection_radii_logs = false
# console logging for ability cooldown update calls
var ability_cooldown_call_logs = false
# console logging for enemy state behaviour
var enemy_state_logs = false
# console logging for enemy dectection functions
var enemy_detection_func_logs = false
# console logging for weapon range checking calls in state_attack.gd
var attack_weapon_range_checking = false
# console logging for audio array controller
var audio_array_controller_logs = false
# console logging for wave handlers and wave spawn master
var wave_spawn_handling_logs = true
