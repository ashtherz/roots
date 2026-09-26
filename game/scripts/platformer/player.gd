extends CharacterBody2D


const MAX_SPEED = 700.0
const JUMP_SPEED = -600.0

const GRAVITY : float = 2
const FLOATINESS : float = 0.8

const BASE_ACCEL : float = 400
const NOT_ON_FLOOR_PENALTY : float = 0.25
const START_ACCEL_FACTOR : float = 4

const DECEL : float = BASE_ACCEL * START_ACCEL_FACTOR
const AIR_RESISTANCE : float = 0.2
const MAX_AIR_DECEL : float = MAX_SPEED * 0.15

const JUMP_PERIOD : float = 0.1
const COYOTE_TIME : float = 0.07  # approx 2 physics frames
const JUMP_HEIGHT_PENALTY_THRESHOLD : float = MAX_SPEED * 0.5
const SPEED_JUMP_HEIGHT_PENALTY : float = 0.4 # Fast -> jump less high

# Speed management
var speed_x : float = 0.0
var speed_y : float = 0.0

# Acceleration is a state machine
# Time since last jump
var jump_time : float = 0.0
# Time since touching the ground
var air_time : float = 0.0

var animation : String = "default"

static func get_x_accel(signed_speed : float, on_floor : bool) -> float:
	var not_on_floor_penalty : float = 1 if on_floor or signed_speed < 0 else NOT_ON_FLOOR_PENALTY
	var accel_factor : float = (START_ACCEL_FACTOR + (1 - START_ACCEL_FACTOR) * signed_speed / (MAX_SPEED))
	return BASE_ACCEL * not_on_floor_penalty * accel_factor

func _physics_process(delta: float) -> void:
	var jumping : bool = false
	if not is_on_floor():
		air_time += delta
	else:
		air_time = 0.0
		animation = "default"

	# Handle jump.
	if Input.is_action_just_pressed("PlatformerJump") and air_time < COYOTE_TIME:
		air_time = COYOTE_TIME
		jump_time = 0.0
		jumping = true
	elif Input.is_action_pressed("PlatformerJump") and jump_time < JUMP_PERIOD:
		jumping = true
	
	if jumping:
		var jump_delta = min(delta, JUMP_PERIOD - jump_time)
		# Penalty: If you are moving fast, you can't jump as high
		var jump_penalty = 1 - pow(clamp((abs(velocity.x) - JUMP_HEIGHT_PENALTY_THRESHOLD) / MAX_SPEED, 0, 1), 0.3) * SPEED_JUMP_HEIGHT_PENALTY
		velocity.y += JUMP_SPEED * jump_penalty * jump_delta / JUMP_PERIOD
		if abs(1 - jump_penalty) < 1e-5:
			animation = "jump_up"
		else:
			animation = "fall"
	else:
		# Fall due to gravity
		var grav_factor : float = FLOATINESS if Input.is_action_pressed("PlatformerJump") else 1.0
		velocity += get_gravity() * GRAVITY * delta * grav_factor
		if velocity.y > 0 and not is_on_floor():
			# If falling down, switch to fall anim
			animation = "fall"
	
	jump_time += delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		if is_on_floor():
			animation = "run"
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, delta * get_x_accel(velocity.x * direction, is_on_floor()))
		if not is_on_floor():
			velocity.x -= sign(velocity.x) * delta * min(MAX_AIR_DECEL, abs(velocity.x) * AIR_RESISTANCE)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * DECEL)
	
	if direction < 0:
		$AnimatedSprite2D.flip_h = false
	
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	
	$AnimatedSprite2D.play(animation)

	move_and_slide()
