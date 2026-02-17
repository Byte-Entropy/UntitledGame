# ******************************************************************************
# * @file    hurtbox.gd
# * @author  Javier
# * @date    2026-02-01
# * @brief   A specialized Area2D component that detects incoming hitboxes 
# * and signals the parent driver to handle interactions.
# ******************************************************************************

# ************************************
# * INCLUDES
# ************************************
class_name Hurtbox
extends Area2D

# ************************************
# * PRIVATE MACROS AND DEFINES
# ************************************

# ************************************
# * VARIABLES
# ************************************

# ************************************
# * FUNCTION DEFINITIONS
# ************************************



# 1. DEFINE THE SIGNAL (This fixes your "missing signal" issue)
signal received_hit(damage: int, knockback: Vector2)

func _ready() -> void:
	# Good practice to set monitoring to true for an Area2D
	monitoring = true
	monitorable = true

# 2. THE HIT FUNCTION
# This is called by the Sword's hitbox
func hit(damage: int, knockback: Vector2) -> void:
	print("Hurtbox hit! Signal emitting...")
	# Pass the signal up to the Slime
	received_hit.emit(damage, knockback)
