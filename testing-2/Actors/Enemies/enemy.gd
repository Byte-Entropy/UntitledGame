
# ******************************************************************************
# * @file    enemy.gd
# * @author  Javier
# * @date    Feb 16, 2026
# * @brief   Base class for all enemy types. Handles health, damage, and death logic.
# ******************************************************************************

# ************************************
# * INCLUDES
# ************************************
class_name Enemy
extends CharacterBody2D

# ************************************
# * VARIABLES
# ************************************

# === Shared Stats ===
@export_category("Enemy Stats")
@export var max_health: int = 30
@export var damage_on_contact: int = 10
@export var move_speed: float = 50.0

# === State Variables ===
var current_health: int
var knockback_velocity: Vector2 = Vector2.ZERO

# === UI REFERENCES ===
@export_category("Enemy Visuals")
@export var health_bar: TextureProgressBar
# ************************************
# * FUNCTION DEFINITIONS
# ************************************

## Called when the node is added to the scene.
## Initializes health to max value.
func _ready() -> void:
	current_health = max_health

	if health_bar:    
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.visible = false

## Handles taking damage and knockback.
##
## @param amount: The amount of damage to apply.
## @param knockback: The knockback vector to apply.
## @return bool: True if the enemy died from this hit, false otherwise.
func take_damage(amount: int, knockback: Vector2) -> bool:
	current_health -= amount
	knockback_velocity = knockback
	# Optionally, add hit reaction here (e.g., modulate = Color.RED)
	if health_bar:
		health_bar.value = current_health
		health_bar.visible = true

	if current_health <= 0:
		die()
		return true
	return false

## Handles enemy death. Override in subclasses for custom death behavior.
func die() -> void:
	queue_free()