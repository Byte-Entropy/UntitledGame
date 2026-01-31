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

# --- Configuration: Stamina Costs ---
const STAMINA_COSTS = {
	"sprint": 25.0,
	"jump": 20.0,
}
const STAMINA_REGEN = 10.0

# --- State Variables ---
var stamina: float = 100.0
var max_stamina: float = 100.0

# --- Z-Axis Simulation ---
var z_height: float = 0.0
var z_velocity: float = 0.0
const GRAVITY_Z = 980.0
const JUMP_FORCE = 300.0

# --- Preloaded Sprites (Auto-loaded from your folder) ---

const TEX_UP = preload("res://PlayerSprites/up.png")
const TEX_DOWN = preload("res://PlayerSprites/down.png")
const TEX_LEFT = preload("res://PlayerSprites/left.png")
const TEX_RIGHT = preload("res://PlayerSprites/right.png")

func _ready() -> void:
	# Safety Check: Print errors if nodes are missing
	if not stamina_bar:
		print("ERROR: Stamina Bar is not assigned in the Inspector!")
	if not sprite:
		# Fallback: Try to find it if not assigned
		sprite = $Sprite2D
		if not sprite: print("ERROR: Sprite2D node not found!")

func to_isometric(dir: Vector2) -> Vector2:
	# isometric projection: x' = x - y, y' = (x + y) / 2
	return Vector2(dir.x - dir.y, (dir.x + dir.y) * 0.5)

func _physics_process(delta: float) -> void:
	# 1. Get Input
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = to_isometric(direction) # Convert to isometric

	# 2. Handle Actions (Sprint)
	var is_sprinting = false
	if direction != Vector2.ZERO and Input.is_action_pressed("move_fast"):
		if stamina > 0:
			is_sprinting = true
			drain_stamina("sprint", delta)

	# 3. Handle Jump (move_jump)
	if Input.is_action_just_pressed("move_jump") and z_height == 0:
		if try_deduct_stamina("jump"):
			z_velocity = -JUMP_FORCE 

	# 4. Apply Physics (Z-Axis Gravity)
	handle_z_axis(delta)

	# 5. Apply Movement (X/Y Axis)
	var current_speed = BASE_SPEED
	if is_sprinting:
		current_speed *= SPRINT_MULTIPLIER

	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		update_facing_direction(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()
	
	# 6. Regen Stamina
	if not is_sprinting:
		handle_regen(delta)

	# 7. Update UI
	update_ui()
	
	# 8. Camera
	handle_camera(delta)

# --- Helper Functions ---

func handle_z_axis(delta: float) -> void:
	if z_height < 0 or z_velocity != 0:
		z_velocity += GRAVITY_Z * delta
		z_height += z_velocity * delta
		
		if z_height >= 0:
			z_height = 0
			z_velocity = 0
			
	# Check if sprite exists before moving it
	if sprite:
		sprite.position.y = z_height

func drain_stamina(action_name: String, delta: float) -> void:
	if action_name in STAMINA_COSTS:
		stamina -= STAMINA_COSTS[action_name] * delta
		stamina = max(stamina, 0)

func try_deduct_stamina(action_name: String) -> bool:
	if action_name in STAMINA_COSTS:
		var cost = STAMINA_COSTS[action_name]
		if stamina >= cost:
			stamina -= cost
			return true
	return false

func handle_regen(delta: float) -> void:
	if stamina < max_stamina:
		stamina += STAMINA_REGEN * delta
		stamina = min(stamina, max_stamina)

func update_ui() -> void:
	if stamina_bar:
		stamina_bar.value = stamina

func update_facing_direction(dir: Vector2) -> void:
	if not sprite: return # Safety check

	# Prioritize axis with stronger input
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.texture = TEX_RIGHT
		else:
			sprite.texture = TEX_LEFT
	else:
		if dir.y > 0:
			sprite.texture = TEX_DOWN
		else:
			sprite.texture = TEX_UP

func handle_camera(delta: float) -> void:
	if camera:
		var cam_input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
		if cam_input:
			camera.position += cam_input * CAM_SPEED * delta
