extends Node

signal camera_move_finished

@export var camera_move_time := 2.0

@onready var player_camera: Camera3D = $"../IntroCamera2"
@onready var tv_camera: Camera3D = $"../TVCameraTarget2/TVPreviewCamera"

var camera_tween: Tween = null


func move_camera_to_tv() -> void:
	if camera_tween != null:
		camera_tween.kill()

	player_camera.make_current()

	camera_tween = create_tween()
	camera_tween.set_parallel(true)

	camera_tween.tween_property(
		player_camera,
		"global_position",
		tv_camera.global_position,
		camera_move_time
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	camera_tween.tween_property(
		player_camera,
		"global_rotation",
		tv_camera.global_rotation,
		camera_move_time
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	camera_tween.tween_property(
		player_camera,
		"fov",
		tv_camera.fov,
		camera_move_time
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	await camera_tween.finished

	player_camera.global_position = tv_camera.global_position
	player_camera.global_rotation = tv_camera.global_rotation
	player_camera.fov = tv_camera.fov

	player_camera.make_current()

	camera_move_finished.emit()
