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
# === Z-Axis Simulation ===
var z_height: float = 0.0
var z_velocity: float = 0.0
const GRAVITY = 980.0
const JUMP_FORCE = 200.0

# ************************************
# * FUNCTION DEFINITIONS
# ************************************



# === State ===
enum State { IDLE, CHASE, HURT }
var current_state = State.IDLE
var chase_target: Node2D = null

func _physics_process(delta: float) -> void:
    # 1. Apply Gravity (The Bounce)
    z_velocity += GRAVITY * delta
    z_height += z_velocity * delta
    
    # 2. Floor Collision (Bounce Logic)
    if z_height >= 0:
        z_height = 0
        
        # If chasing, jump again immediately!
        if current_state == State.CHASE and chase_target:
            z_velocity = -JUMP_FORCE
            # Calculate direction towards player ONLY when launching
            var direction = global_position.direction_to(chase_target.global_position)
            velocity = direction * 50.0 # Move speed
        else:
            z_velocity = 0
            velocity = Vector2.ZERO # Stop moving when on ground
            
    # 3. Visuals
    $Visuals.position.y = z_height # Visuals go up/down
    move_and_slide()

# === Signal Connection from Hurtbox ===
func _on_hurtbox_received_hit(damage: int, knockback: Vector2) -> void:
    health -= damage
    velocity = knockback * 300.0 # Apply instant Knockback
    z_velocity = -150.0 # Pop it into the air a bit (Juice!)
    current_state = State.HURT
    # Add a timer or logic to return to CHASE