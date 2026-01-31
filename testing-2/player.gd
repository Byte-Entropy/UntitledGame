extends CharacterBody2D

# --- Node References ---
@export var stamina_bar: TextureProgressBar
@export var camera: Camera2D
@export var sprite: Sprite2D 

# --- Configuration: Movement ---
const BASE_SPEED = 100.0
const SPRINT_MULTIPLIER = 2.0
const FRICTION = 1200.0
const CAM_SPEED = 500.0

# --- Configuration: Animation (Bobbing) ---
const BOB_FREQUENCY = 10.0  # How fast the bob is
const BOB_AMPLITUDE = 3.0   # How many pixels up/down

# --- Configuration: Stamina Costs ---
const STAMINA_COSTS = {
    "sprint": 20.0,
    "jump": 15.0,
}
const STAMINA_REGEN = 10.0

# --- State Machine ---
enum State { IDLE, MOVE, JUMP, ROLL, ATTACK, BLOCK }
var current_state = State.IDLE

# --- State Variables ---
var stamina: float = 100.0
var max_stamina: float = 100.0
var is_exhausted: bool = false

# --- Z-Axis & Visuals ---
var z_height: float = 0.0
var z_velocity: float = 0.0
var bob_time: float = 0.0 # Tracks time for the sine wave
const GRAVITY_Z = 980.0
const JUMP_FORCE = 300.0

# --- Preloaded Sprites ---
const TEX_UP = preload("res://PlayerSprites/up.png")
const TEX_DOWN = preload("res://PlayerSprites/down.png")
const TEX_LEFT = preload("res://PlayerSprites/left.png")
const TEX_RIGHT = preload("res://PlayerSprites/right.png")

func _ready() -> void:
    if not stamina_bar: print("ERROR: Stamina Bar missing!")
    if not sprite: 
        sprite = $Sprite2D
        if not sprite: print("ERROR: Sprite2D missing!")

func to_isometric(dir: Vector2) -> Vector2:
    return Vector2(dir.x - dir.y, (dir.x + dir.y) * 0.5)

func _physics_process(delta: float) -> void:
    # Global Input
    handle_camera(delta)
    
    # Movement Input
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var iso_dir = to_isometric(input_dir)
    
    # === State Machine Logic ===
    match current_state:
        State.IDLE:
            handle_idle_state(iso_dir, delta)
        State.MOVE:
            handle_move_state(iso_dir, delta)
        State.JUMP:
            handle_jump_state(iso_dir, delta)
        State.ROLL:
            handle_roll_state(iso_dir, delta)
        State.ATTACK:
            handle_attack_state(iso_dir, delta)
        State.BLOCK:
            handle_block_state(iso_dir, delta)
    # === End State Machine Logic ===
    
    # Apply Physics (Slide)
    move_and_slide()
    
    # Global Visual Updates (Facing, Z-Axis, UI)
    update_visuals(iso_dir, delta)
    update_ui()

# --- State Functions ---

func handle_idle_state(dir: Vector2, delta: float) -> void:
    # Transition: If input, switch to MOVE
    if dir != Vector2.ZERO:
        current_state = State.MOVE
        return

    # Transition: Jump
    if Input.is_action_just_pressed("move_jump") and try_deduct_stamina("jump"):
        start_jump()
        return

    # Apply Friction
    velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
    handle_regen(delta)

func handle_move_state(dir: Vector2, delta: float) -> void:
    # Transition: If no input, switch to IDLE
    if dir == Vector2.ZERO:
        current_state = State.IDLE
        return

    # Transition: Jump
    if Input.is_action_just_pressed("move_jump") and try_deduct_stamina("jump"):
        start_jump()
        return

    var current_speed = BASE_SPEED

    # Stamina Exhaustion Logic
    if stamina <= 0:
        is_exhausted = true
    elif stamina >= max_stamina * 0.15:
        is_exhausted = false


    if Input.is_action_pressed("move_fast") and not is_exhausted:
        if stamina > 0:
            current_speed *= SPRINT_MULTIPLIER
            drain_stamina("sprint", delta)
    else:
        handle_regen(delta)

    velocity = dir * current_speed

func handle_jump_state(dir: Vector2, delta: float) -> void:
    var current_speed = BASE_SPEED
    if Input.is_action_pressed("move_fast") and not is_exhausted:
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

func handle_roll_state(dir: Vector2, delta: float) -> void:
    pass

func handle_attack_state(dir: Vector2, delta: float) -> void:
    pass

func handle_block_state(dir: Vector2, delta: float) -> void:
    pass

# --- Visuals & Helpers ---

func start_jump() -> void:
    current_state = State.JUMP
    z_velocity = -JUMP_FORCE

func update_visuals(dir: Vector2, delta: float) -> void:
    if not sprite: return
    
    # 1. Facing Direction
    if dir != Vector2.ZERO:
        update_facing_direction(dir)
    
    # 2. Bobbing Calculation (Only when moving on ground)
    var bob_offset = 0
    if current_state == State.MOVE:
        bob_time += delta * BOB_FREQUENCY
        bob_offset = sin(bob_time) * BOB_AMPLITUDE
    else:
        bob_time = 0.0

    # 3. Combine Z-Height (Jump) and Bobbing (Walk)
    sprite.position.y = z_height - abs(bob_offset) 

func update_facing_direction(dir: Vector2) -> void:
    # Prioritize axis with stronger input
    if abs(dir.x) > abs(dir.y):
        sprite.texture = TEX_RIGHT if dir.x > 0 else TEX_LEFT
    else:
        sprite.texture = TEX_DOWN if dir.y > 0 else TEX_UP

func drain_stamina(action: String, delta: float) -> void:
    if action in STAMINA_COSTS:
        stamina = max(stamina - STAMINA_COSTS[action] * delta, 0)

func try_deduct_stamina(action: String) -> bool:
    if action in STAMINA_COSTS and stamina >= STAMINA_COSTS[action]:
        stamina -= STAMINA_COSTS[action]
        return true
    return false

func handle_regen(delta: float) -> void:
    stamina = min(stamina + STAMINA_REGEN * delta, max_stamina)

func update_ui() -> void:
    if stamina_bar: stamina_bar.value = stamina

func handle_camera(delta: float) -> void:
    if camera:
        var cam_input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
        if cam_input: camera.position += cam_input * CAM_SPEED * delta