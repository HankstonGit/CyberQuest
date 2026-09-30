extends CharacterBody3D

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

# The classroom intro begins locked.
var intro_locked := true

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: SophiaSkin = %SophiaSkin


func _ready() -> void:
	if intro_locked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_skin.idle()


func _input(event: InputEvent) -> void:
	if intro_locked:
		return

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if intro_locked:
		_camera_input_direction = Vector2.ZERO
		return

	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity


func _physics_process(delta: float) -> void:

	# CAMERA
	if not intro_locked:
		_camera_pivot.rotation.x += _camera_input_direction.y * delta
		_camera_pivot.rotation.x = clamp(
			_camera_pivot.rotation.x,
			tilt_lower_limit,
			tilt_upper_limit
		)

		_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO


	# MOVEMENT
	var move_direction := Vector3.ZERO

	if not intro_locked:
		var raw_input := Input.get_vector(
			"move_left",
			"move_right",
			"move_up",
			"move_down"
		)

		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x

		move_direction = forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()


	# Keep gravity working even while the intro is locked.
	var y_velocity := velocity.y

	velocity.y = 0.0

	if intro_locked:
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		velocity = velocity.move_toward(
			move_direction * move_speed,
			acceleration * delta
		)

	velocity.y = y_velocity + _gravity * delta


	# JUMP
	var is_starting_jump := false

	if not intro_locked:
		is_starting_jump = (
			Input.is_action_just_pressed("jump")
			and is_on_floor()
		)

	if is_starting_jump:
		velocity.y += jump_impulse


	move_and_slide()


	# CHARACTER ROTATION
	if not intro_locked:
		if move_direction.length() > 0.2:
			_last_movement_direction = move_direction

		var target_angle := Vector3.BACK.signed_angle_to(
			_last_movement_direction,
			Vector3.UP
		)

		_skin.global_rotation.y = lerp_angle(
			_skin.rotation.y,
			target_angle,
			rotation_speed * delta
		)


	# ANIMATIONS
	if intro_locked:
		_skin.idle()

	elif is_starting_jump:
		_skin.jump()

	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()

	elif is_on_floor():
		var ground_speed := Vector2(velocity.x, velocity.z).length()

		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()


func set_intro_locked(locked: bool) -> void:
	intro_locked = locked
	_camera_input_direction = Vector2.ZERO

	if locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_skin.idle()
