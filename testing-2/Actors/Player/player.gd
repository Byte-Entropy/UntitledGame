# ******************************************************************************
# * @file    player.gd
# * @author  Javier
# * @date    Feb 01, 2026
# * @brief   Controls the main character. Handles isometric movement, state 
# * machine logic (Idle, Move, Jump, Roll), stamina management, 
# * and Z-axis visual simulation.
# ******************************************************************************

# ************************************
# * INCLUDES
# ************************************
extends CharacterBody2D

# ************************************
# * VARIABLES
# ************************************

# === State Variables ===
var health: int = 100
var is_invincible: bool = false

# === Node References ===
@onready var hurtbox: Hurtbox = get_parent().get_node_or_null("Hurtbox")

# === Node References ===
@export var stamina_bar: TextureProgressBar
@export var camera: Camera2D
@export var sprite: Sprite2D 

# === Configuration: Movement ===
const BASE_SPEED = 100.0
const SPRINT_MULTIPLIER = 2.0
const FRICTION = 1200.0
const CAM_SPEED = 500.0

# === Configuration: Animation (Bobbing) ===
const BOB_FREQUENCY = 10.0  
const BOB_AMPLITUDE = 4.3   

# === Configuration: Stamina & Resources ===
const STAMINA_COSTS = {
	"sprint": 20.0,
	"jump": 15.0,
	"roll": 15.0
}
const STAMINA_REGEN = 10.0

# === Configuration: Rolling ===
const ROLL_SPEED = 250.0
const ROLL_DURATION = 0.5
const RECOVERY_DURATION = 0.15 

# === State Machine ===
enum State { IDLE, MOVE, JUMP, ROLL, RECOVERY, ATTACK, BLOCK }

## Current active state of the player. Defaults to IDLE.
var current_state = State.IDLE

# === State Variables ===
var stamina: float = 100.0
var max_stamina: float = 100.0
var is_exhausted: bool = false
var roll_timer: float = 0.0
var recovery_timer: float = 0.0
var roll_queued: bool = false 

## The locked direction vector for the current roll.
var current_roll_dir: Vector2 = Vector2.ZERO

# === Z-Axis & Visuals ===
const GRAVITY_Z = 980.0
const JUMP_FORCE = 300.0

var z_height: float = 0.0
var z_velocity: float = 0.0
var bob_time: float = 0.0 

# === Preloaded Sprites ===
const TEX_UP = preload("res://Actors/Player/assets/N.png")
const TEX_DOWN = preload("res://Actors/Player/assets/S.png")
const TEX_LEFT = preload("res://Actors/Player/assets/W.png")
const TEX_RIGHT = preload("res://Actors/Player/assets/E.png")


# ************************************
# * FUNCTION DEFINITIONS
# ************************************

func _ready() -> void:
	if not stamina_bar: print("ERROR: Stamina Bar missing!")
	if not sprite: 
		sprite = $Sprite2D
		if not sprite: print("ERROR: Sprite2D missing!")
	if not camera:
		camera = $Camera2D
		if not camera: print("ERROR: Camera2D missing!")
	if hurtbox:
		hurtbox.received_hit.connect(_on_received_hit)

## Converts a standard Cartesian vector (2D top-down) into Isometric projection.
##
## @param dir: The input direction vector (e.g., from Input.get_vector).
## @return Vector2: The projected vector adjusted for 2:1 isometric view.
func to_isometric(dir: Vector2) -> Vector2:
	return Vector2(dir.x - dir.y, (dir.x + dir.y) * 0.5)

## Main physics loop. Handles Input -> State Logic -> Physics Slide -> Visuals.
func _physics_process(delta: float) -> void:
	# 1. Global Input
	handle_camera(delta)
	
	# 2. Movement Input
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var iso_dir = to_isometric(input_dir)
	
	# 3. State Machine Logic
	match current_state:
		State.IDLE:     handle_idle_state(iso_dir, delta)
		State.MOVE:     handle_move_state(iso_dir, delta)
		State.JUMP:     handle_jump_state(iso_dir, delta)
		State.ROLL:     handle_roll_state(iso_dir, delta)
		State.ATTACK:   handle_attack_state(iso_dir, delta)
		State.BLOCK:    handle_block_state(iso_dir, delta)
		State.RECOVERY: pass 

	# 4. Apply Physics (Slide)
	move_and_slide()
	
	# 5. Global Visual Updates
	update_visuals(iso_dir, delta)
	update_ui()
	running_particle_effect()

# ================
# === ON EVENT ===
# ================

## Driver-level handler for when the hurtbox detects a hit.
## Determines if damage should be applied based on current player state.
##
## @param damage: The amount of health to deduct.
## @param knockback: The vector force to apply to the player's velocity.
func _on_received_hit(damage: int, knockback: Vector2) -> void:
	# Determine if interaction is valid
	if is_invincible or current_state == State.ROLL:
		print_debug("Player hit ignored due to invincibility or rolling.")
		return  # Iframes
	
	# Apply damage and knockback
	health -= damage
	velocity = knockback

	print_debug("Player hit! Health remaining: ", health)


# ======================
# === STATE HANDLERS ===
# ======================


## Handles logic when the player is standing still.
## Transitions to MOVE, JUMP, or ROLL based on input.
##
## @param dir: The current input direction (used to trigger movement).
## @param delta: Time step for applying friction and regen.
func handle_idle_state(dir: Vector2, delta: float) -> void:
	# Transition: If input, switch to MOVE
	if dir != Vector2.ZERO:
		current_state = State.MOVE
		return

	# Transition: Jump
	if Input.is_action_just_pressed("move_jump") and try_deduct_stamina("jump"):
		start_jump()
		return

	# Transition: Roll
	if Input.is_action_just_pressed("move_roll") and try_deduct_stamina("roll"):
		start_roll(dir)
		return

	# Apply Friction
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	handle_regen(delta)

## Handles logic when the player is walking or sprinting.
## Manages stamina drain during sprints and transitions to IDLE/JUMP/ROLL.
##
## @param dir: The input direction vector for movement.
## @param delta: Time step for movement calculations and stamina drain.
func handle_move_state(dir: Vector2, delta: float) -> void:
	# Transition: If no input, switch to IDLE
	if dir == Vector2.ZERO:
		current_state = State.IDLE
		return

	# Transition: Jump
	if Input.is_action_just_pressed("move_jump") and try_deduct_stamina("jump"):
		start_jump()
		return

	# Transition: Roll
	if Input.is_action_just_pressed("move_roll") and try_deduct_stamina("roll"):
		start_roll(dir)
		return


	# === DEFAULT MOVE LOGIC ===
	var current_speed = BASE_SPEED
	# === DEFAULT MOVE LOGIC ===

	# Stamina Exhaustion Logic
	if stamina <= 0:
		is_exhausted = true
	elif stamina >= max_stamina * 0.15:
		is_exhausted = false


	if Input.is_action_pressed("move_sprint") and not is_exhausted:
		if stamina > 0:
			current_speed *= SPRINT_MULTIPLIER
			drain_stamina("sprint", delta)
	else:
		handle_regen(delta)

	velocity = dir * current_speed

## Handles the Z-axis jump physics and air movement.
## Applies gravity to z_velocity and updates z_height.
##
## @param dir: Input direction. Allows for limited air control if desired.
## @param delta: Time step for gravity calculation.
func handle_jump_state(dir: Vector2, delta: float) -> void:
	var current_speed = BASE_SPEED
	if Input.is_action_pressed("move_sprint") and not is_exhausted:
		current_speed *= SPRINT_MULTIPLIER
	
	if dir != Vector2.ZERO:
		velocity = dir * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# Gravity Logic
	z_velocity += GRAVITY_Z * delta
	z_height += z_velocity * delta
	
	# Landing Logic
	if z_height >= 0:
		z_height = 0
		z_velocity = 0
		current_state = State.IDLE # Return to ground state

## Handles the rolling state. Manages duration, ghost spawning, and input buffering.
##
## @param dir: Input direction (unused for movement, used for queueing next roll).
## @param delta: Time step.
func handle_roll_state(dir: Vector2, delta: float) -> void:
	roll_timer -= delta
	
	# 1. Input Queueing (The Memory)
	if Input.is_action_just_pressed("move_roll"):
		roll_queued = true 

	# 2. Visuals
	if Engine.get_physics_frames() % 5 == 0:
		spawn_ghost()

	# 3. Interrupt Check (The Flag Logic)
	# The event "roll_timer <= 0" acts as your "Roll Completed" flag.
	if roll_timer <= 0:
		check_roll_queue(dir)
	else:
		velocity = current_roll_dir * ROLL_SPEED


## Placeholder for Attack state logic.
func handle_attack_state(dir: Vector2, delta: float) -> void:
	dir = dir  
	delta = delta  
	pass

## Placeholder for Block state logic.
func handle_block_state(dir: Vector2, delta: float) -> void:
	dir = dir  
	delta = delta  
	pass



# =================
# === ON ACTION ===
# =================

func _on_player_hurt(damage: int, knockback: Vector2) -> void:
	# Perform "on_contact" actions here
	health -= damage
	velocity = knockback
	print("Ouch! Remaining health: ", health)

# ========================
# === HELPER FUNCTIONS ===
# ========================

## Initiates a jump by setting state and vertical velocity.
func start_jump() -> void:
	current_state = State.JUMP
	z_velocity = -JUMP_FORCE

## Initiates a roll. Locks the movement direction for the duration.
##
## @param dir: The intended direction of the roll.
func start_roll(dir: Vector2) -> void:
	# Sanity Check: Prevent rolling while standing completely still
	if dir == Vector2.ZERO and velocity == Vector2.ZERO:
		return 

	# Set State
	current_state = State.ROLL
	roll_timer = ROLL_DURATION
	
	# Determine Direction
	# If player is holding a key (changing direction), use that.
	if dir != Vector2.ZERO:
		current_roll_dir = dir.normalized()
	# Otherwise, maintain momentum (allows straight chaining)
	else:
		current_roll_dir = velocity.normalized()
		
	velocity = current_roll_dir * ROLL_SPEED
	spawn_ghost() # Pop the first ghost instantly


## Drains stamina over time for continuous actions (like sprinting).
##
## @param action: The string key (e.g., "sprint") to look up cost.
## @param delta: Time step to multiply the cost by.
func drain_stamina(action: String, delta: float) -> void:
	if action in STAMINA_COSTS:
		stamina = max(stamina - STAMINA_COSTS[action] * delta, 0)

## Attempts to deduct a flat amount of stamina for an action.
##
## @param action: The string key (e.g., "jump", "roll") to look up cost.
## @return bool: True if stamina was sufficient and deducted; False otherwise.
func try_deduct_stamina(action: String) -> bool:
	if action in STAMINA_COSTS and stamina >= STAMINA_COSTS[action]:
		stamina -= STAMINA_COSTS[action]
		return true
	return false

## Regenerates stamina when not performing exhausting actions.
func handle_regen(delta: float) -> void:
	stamina = min(stamina + STAMINA_REGEN * delta, max_stamina)

## Updates the UI bar to match current stamina values.
func update_ui() -> void:
	if stamina_bar: stamina_bar.value = stamina


## Checks if a roll was queued during the previous action.
## If yes, transitions immediately to a new roll (if stamina allows).
## If no, returns to IDLE.
##
## @param dir: The current input direction to start the new roll towards.
func check_roll_queue(dir: Vector2) -> void:
	# LOGIC: (Roll Completed) AND (Roll Queued)
	if roll_queued:
		roll_queued = false # Consume the flag
		
		# Try to execute the queued action
		if try_deduct_stamina("roll"):
			# Note: start_roll handles direction logic. 
			# If 'dir' is held, it changes direction. 
			# If 'dir' is empty, it continues momentum.
			start_roll(dir)
		else:
			# Queued, but no stamina -> Fail to Idle
			velocity = Vector2.ZERO
			current_state = State.IDLE
	else:
		# Roll Completed AND (NOT Queued) -> Stop
		velocity = Vector2.ZERO
		current_state = State.IDLE

## Moves the camera based on "camera_*" inputs.
## Independent of player movement.
func handle_camera(delta: float) -> void:
	if camera:
		var cam_input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
		if cam_input: camera.position += cam_input * CAM_SPEED * delta



# ========================
# === VISUAL FUNCTIONS ===
# ========================



## Updates the sprite's texture and position based on state.
## Combines the Z-axis height (jump) with the sine-wave bobbing (walk).
##
## @param dir: The input direction, used to determine facing (N/S/E/W).
## @param delta: Time step for updating the bobbing animation timer.
func update_visuals(dir: Vector2, delta: float) -> void:
	if not sprite: return
	
	# 1. Facing Direction
	if dir != Vector2.ZERO:
		update_facing_direction(dir)
	
	# 2. Bobbing Calculation (Only when moving on ground)
	var bob_offset = 0.00
	if current_state == State.MOVE:
		bob_time += delta * BOB_FREQUENCY
		bob_offset = sin(bob_time) * BOB_AMPLITUDE
	else:
		bob_time = 0.0

	# 3. Combine Z-Height (Jump) and Bobbing (Walk)
	sprite.position.y = z_height - abs(bob_offset) 

## Selects the correct sprite texture based on the movement axis.
## Prioritizes the axis with the stronger input magnitude.
##
## @param dir: The input direction vector.
func update_facing_direction(dir: Vector2) -> void:
	# Prioritize axis with stronger input
	if abs(dir.x) > abs(dir.y):
		sprite.texture = TEX_RIGHT if dir.x > 0 else TEX_LEFT
	else:
		sprite.texture = TEX_DOWN if dir.y > 0 else TEX_UP

## Spawns a static "ghost" copy of the sprite for the roll trail effect.
## The ghost fades out and deletes itself automatically.
func spawn_ghost() -> void:
	# Create ghost sprite
	var ghost = Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.scale = sprite.scale
	
	# Match position
	ghost.global_position = sprite.global_position
	ghost.z_index = sprite.z_index  # Draw on player
	ghost.modulate.a = 0.5 # Start semi-transparent
	
	get_tree().current_scene.add_child(ghost)
	
	# Animate fade out
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3) # Fade to 0 over 0.3s
	tween.tween_callback(ghost.queue_free) # Delete after fade

## Checks movement conditions and emits particles if sprinting on the ground.
func running_particle_effect() -> void:
	# Check State and Speed
	if current_state == State.MOVE and velocity.length() > (BASE_SPEED*1.34):

		# Detect ground contact
		if z_height == 0:

			# Match particle texture to block type  
			var particles = $RunningParticles2D

			# Orient particles opposite to movement direction
			var particle_dir: Vector2 = Vector2.ZERO
			particle_dir = -velocity.normalized()

			
			particles.direction = particle_dir
			particles.emitting = true
			# Call parent get_terrain_color_at() to get color
			#particles.color = get_parent().get_terrain_color_at(global_position).
			particles.color = Color(1,1,1,1)  # Placeholder white color
			# Fade particles based on speed
			var speed_factor = clamp((velocity.length() - BASE_SPEED) / (BASE_SPEED * (SPRINT_MULTIPLIER - 1)), 0.0, 1.0)
			particles.scale_amount_max = 1.0 + speed_factor * 4.0
			particles.z_index = sprite.z_index - 1  # Draw behind player
			

		else:
			$RunningParticles2D.emitting = false
	else:
		$RunningParticles2D.emitting = false
