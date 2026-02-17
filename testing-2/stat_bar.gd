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

@onready var real_bar: TextureProgressBar = $RealBar
@onready var ghost_bar: TextureProgressBar = $GhostBar
@onready var timer: Timer = $Timer

var target_value: float = 100.0


# ************************************
# * FUNCTION DEFINITIONS
# ************************************

## Initializes the stat bar. Sets up the timer and connects signals.
##
## @param void
## @return void
func _ready() -> void:
    # Setup initial values
    real_bar.value = target_value
    ghost_bar.value = target_value
    
    # Setup Timer (Wait 0.4s before shrinking ghost)
    timer.wait_time = 0.4
    timer.one_shot = true
    timer.timeout.connect(_on_timer_timeout)

## Call this function when the player takes damage or uses stamina
##
## @param new_value: The new value for the stat (e.g., health or stamina)
## @return void
func set_value(new_value: float) -> void:
    var prev_value = real_bar.value
    target_value = new_value
    
    # Update the REAL bar instantly
    real_bar.value = target_value
    
    # LOGIC:
    # If we lost health (Damage), start the ghost timer.
    if new_value < prev_value:
        timer.start() 
    # If we gained health (Heal), snap the ghost immediately to match.
    else:
        ghost_bar.value = new_value

## When the timer ends, smoothly tween the ghost bar down
##
## @param void
## @return void
func _on_timer_timeout() -> void:
    var tween = create_tween()
    tween.tween_property(ghost_bar, "value", target_value, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)