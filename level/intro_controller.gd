extends Node

@export var camera_move_time := 2.0

var dialogue_manager: Node = null
var player_camera: Camera3D = null
var tv_camera_target: Marker3D = null


func _ready() -> void:
	dialogue_manager = get_tree().current_scene.find_child(
		"DialogueManager",
		true,
		false
	)

	tv_camera_target = get_tree().current_scene.find_child(
		"TVCameraTarget",
		true,
		false
	)

	player_camera = get_viewport().get_camera_3d()


	if dialogue_manager == null:
		push_error("IntroController could not find DialogueManager.")
		return

	if tv_camera_target == null:
		push_error("IntroController could not find TVCameraTarget.")
		return

	if player_camera == null:
		push_error("IntroController could not find the active Camera3D.")
		return


	dialogue_manager.conversation_finished.connect(
		_on_conversation_finished
	)


func _on_conversation_finished() -> void:
	move_camera_to_tv()


func move_camera_to_tv() -> void:
	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		player_camera,
		"global_position",
		tv_camera_target.global_position,
		camera_move_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		player_camera,
		"global_rotation",
		tv_camera_target.global_rotation,
		camera_move_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
