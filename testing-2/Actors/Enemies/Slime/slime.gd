
# ******************************************************************************
# * @file    slime.gd
# * @author  Javier
# * @date    Feb 16, 2026
# * @brief   Slime enemy logic. Handles bouncing, Z-axis, and hit reactions.
# ******************************************************************************

# ************************************
# * INCLUDES
# ************************************
extends Enemy

# ************************************
# * VARIABLES
# ************************************

# === Slime Specific Settings ===
const GRAVITY = 980.0
const JUMP_FORCE = 200.0

# === Z-Axis Logic ===
var z_height: float = 0.0
var z_velocity: float = 0.0

# === AI State ===
enum State { IDLE, CHASE, HURT }
var current_state = State.IDLE
var chase_target: Node2D = null # Player reference

# ************************************
# * FUNCTION DEFINITIONS
# ************************************

## Called when the node is added to the scene.
## Initializes health and runs parent logic.
func _ready() -> void:
	super._ready() # Important! Runs the Enemy.gd _ready() to set health.

## Main physics loop. Handles gravity, bouncing, and movement.
##
## @param delta: Time step for physics calculations.
func _physics_process(delta: float) -> void:
	# 1. Apply Gravity (Z-Axis)
	z_velocity += GRAVITY * delta
	z_height += z_velocity * delta
	# 2. Floor Collision & Movement Logic
	if z_height >= 0:
		z_height = 0
		# SLIME LOGIC: Only move when we bounce
		if current_state == State.CHASE and chase_target:
			z_velocity = -JUMP_FORCE
			# Use 'move_speed' from the Parent Class
			var direction = global_position.direction_to(chase_target.global_position)
			velocity = direction * move_speed
		else:
			z_velocity = 0
			velocity = Vector2.ZERO
	# 3. Visuals
	$Visuals.position.y = z_height
	move_and_slide() # Uses the 'velocity' we set above

## Called when the hurtbox receives a hit.
## Handles damage, knockback, and hurt state.
##
## @param damage_amount: The amount of damage received.
## @param knockback: The knockback vector to apply.
func _on_hurtbox_received_hit(damage_amount: int, knockback: Vector2) -> void:
	# 1. Update the Data (Parent Class Logic)
	var died = take_damage(damage_amount, knockback)
	if died:
		return # Stop logic if dead
	# 2. Slime Specific Reaction
	# Slimes are bouncy, so they fly backwards and UP when hit
	velocity = knockback * 300.0
	z_velocity = -150.0
	current_state = State.HURT
	# Simple recovery timer (could be a Timer node instead)
	await get_tree().create_timer(0.4).timeout
	current_state = State.IDLE
