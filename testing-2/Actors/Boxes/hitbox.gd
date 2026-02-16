class_name Hitbox
extends Area2D

@export var damage: int = 10

## Returns the damage amount for this interaction.
func get_damage() -> int:
    return damage

## Returns the knockback vector. 
## We calculate this dynamically based on the parent's position relative to the target.
func get_knockback_vector() -> Vector2:
    # Assumes the parent (Player/Sword) is the source of the force.
    # You can also pass the "facing direction" if you prefer.
    return global_position.direction_to(get_global_mouse_position()) # Placeholder logic