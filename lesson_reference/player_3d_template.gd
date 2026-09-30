extends CharacterBody3D

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var jump_impulse := 12.0
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0


# Classroom intro begins locked.
var intro_locked := true

var ground_height := 0.0

var _gravity := -30.0
var _was_on_floor_last_frame := true
var _camera_input_direction := Vector2.ZERO

var _last_input_direction := Vector3.BACK
var _start_position := Vector3.ZERO

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: SophiaSkin = %SophiaSkin
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var _dust_particles: GPUParticles3D = %DustParticles


func _ready() -> void:
	# Find the classroom spawn marker.
	var spawn_point = get_tree().current_scene.find_child(
		"SpawnPoint",
		true,
		false
	)

	# If SpawnPoint exists, start the player there.
	if spawn_point is Marker3D:
		global_transform = spawn_point.global_transform

	# Save the real starting position AFTER moving to DeskSpawn.
	_start_position = global_position
	_last_input_direction = global_basis.z


	Events.kill_plane_touched.connect(func on_kill_plane_touched() -> void:
		global_position = _start_position
		velocity = Vector3.ZERO
		_skin.idle()
		set_physics_process(true)
	)

	Events.flag_reached.connect(func on_flag_reached() -> void:
		set_physics_process(false)
		_skin.idle()
		_dust_particles.emitting = false
	)

	if intro_locked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_skin.idle()


func _input(event: InputEvent) -> void:
	# Escape always releases the mouse for the pause menu.
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	if intro_locked:
		return

	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if intro_locked:
		_camera_input_direction = Vector2.ZERO
		return

	var player_is_using_mouse := (
		event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if player_is_using_mouse:
		_camera_input_direction.x = -event.relative.x * mouse_sensitivity
		_camera_input_direction.y = -event.relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:

	# During the intro, keep the mouse captured whenever the game isn't paused.
	if intro_locked and not get_tree().paused:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


	# CAMERA
	if not intro_locked:
		_camera_pivot.rotation.x += _camera_input_direction.y * delta

		_camera_pivot.rotation.x = clamp(
			_camera_pivot.rotation.x,
			tilt_lower_limit,
			tilt_upper_limit
		)

		_camera_pivot.rotation.y += _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO


	# MOVEMENT INPUT
	var move_direction := Vector3.ZERO

	if not intro_locked:
		var raw_input := Input.get_vector(
			"move_left",
			"move_right",
			"move_up",
			"move_down",
			0.4
		)

		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x

		move_direction = forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()


	# CHARACTER ROTATION
	if not intro_locked:
		if move_direction.length() > 0.2:
			_last_input_direction = move_direction.normalized()

		var target_angle := Vector3.BACK.signed_angle_to(
			_last_input_direction,
			Vector3.UP
		)

		_skin.global_rotation.y = lerp_angle(
			_skin.rotation.y,
			target_angle,
			rotation_speed * delta
		)


	# HORIZONTAL MOVEMENT + GRAVITY
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

		if (
			is_equal_approx(move_direction.length_squared(), 0.0)
			and velocity.length_squared() < stopping_speed
		):
			velocity = Vector3.ZERO

	velocity.y = y_velocity + _gravity * delta


	# JUMP
	var is_just_jumping := false

	if not intro_locked:
		is_just_jumping = (
			Input.is_action_just_pressed("jump")
			and is_on_floor()
		)

	if is_just_jumping:
		velocity.y += jump_impulse
		_skin.jump()
		_jump_sound.play()


	# ANIMATIONS
	if intro_locked:
		_skin.idle()

	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()

	elif is_on_floor():
		var ground_speed := Vector2(
			velocity.x,
			velocity.z
		).length()

		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()


	# PARTICLES
	var ground_speed := Vector2(
		velocity.x,
		velocity.z
	).length()

	_dust_particles.emitting = (
		not intro_locked
		and is_on_floor()
		and ground_speed > 0.0
	)


	# LANDING SOUND
	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()

	_was_on_floor_last_frame = is_on_floor()

	move_and_slide()


func set_intro_locked(locked: bool) -> void:
	intro_locked = locked
	_camera_input_direction = Vector2.ZERO

	if locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_skin.idle()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
