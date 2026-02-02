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

# === Signals ===
## Emitted when a valid hitbox is detected.
## @param damage: The amount of damage passed by the hitbox.
## @param knockback: The direction and force of the impact.
signal received_hit(damage: int, knockback: Vector2)

# ************************************
# * FUNCTION DEFINITIONS
# ************************************

func _ready() -> void:
	# Connect internal signal to handle detections
	area_entered.connect(_on_area_entered)


## Internal listener for Area2D collisions. 
## Validates the entering area and forwards data to the driver.
##
## @param area: The Area2D that entered the hurtbox.
## @return void
func _on_area_entered(area: Area2D) -> void:
	# Driver-led check: Ensure the area can provide combat data
	if area.has_method("get_damage"):
		var damage = area.get_damage()
		var knockback = area.get_knockback_vector()
		
		received_hit.emit(damage, knockback)