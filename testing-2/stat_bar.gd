# ******************************************************************************
# * @file    <filename>
# * @author  Javier
# * @date    <date>
# * @brief   <description>
# ******************************************************************************
# ************************************
# * INCLUDES
# ************************************

extends Control


# ------------------------------------

# ************************************
# * PRIVATE MACROS AND DEFINES
# ************************************
# (optional)

# ------------------------------------

# ************************************
# * VARIABLES
# ************************************
# References
@onready var real_bar: TextureProgressBar = $RealBar
@onready var ghost_bar: TextureProgressBar = $GhostBar
@onready var timer: Timer = $Timer

# Properties with Setters
@export var max_value: float = 100.0:
	set(value):
		max_value = value
		if is_inside_tree():
			real_bar.max_value = max_value
			ghost_bar.max_value = max_value

@export var value: float = 100.0:
	set(new_value):
		# Detect if we are taking damage (new < old) or healing
		var prev_value = value
		value = new_value
		if is_inside_tree():
			_update_bars(prev_value)

# ************************************
# * FUNCTION DEFINITIONS
# ************************************

## Initializes the stat bar. Sets up the timer and connects signals.
##
## @param void
## @return void
func _ready() -> void:
	# Initialize bars
	real_bar.max_value = max_value
	ghost_bar.max_value = max_value
	real_bar.value = value
	ghost_bar.value = value
	
	# Setup Timer (Adjust wait_time for how long Yellow stays still)
	timer.wait_time = 0.5 
	timer.one_shot = true

## Call this function when the player takes damage or uses stamina
##
## @param prev_value: The previous value for the stat (e.g., health or stamina)
## @return void
func _update_bars(prev_value: float) -> void:
	# 1. Update the Real Bar immediately
	real_bar.value = value
	
	# 2. Check for Damage (Current Value < Previous Value)
	if value < prev_value:
		# Start the timer to delay the Ghost Bar shrinking
		timer.start()
	else:
		# Healing: Update Ghost Bar immediately to match (hide it)
		ghost_bar.value = value
		timer.stop() # Cancel any pending shrink if we healed

## When the timer ends, smoothly tween the ghost bar down
##
## @param void
## @return void
func _on_timer_timeout() -> void:
	# Create a tween for the smooth animation
	var tween = create_tween()
	
	# Tween the Ghost Bar to the current Real Bar value
	# Duration: 0.4 seconds (adjust '0.4' for speed of shrink)
	tween.tween_property(ghost_bar, "value", value, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)