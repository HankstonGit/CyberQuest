extends Node

var dialogue = null
var intro_camera: Camera3D = null
var tv_camera_target: Marker3D = null

var messages = [
	"Welcome to CyberQuest.",
	"Before we begin, let's go over some cybersecurity basics.",
	"Cybersecurity is about protecting devices, accounts, and information from unauthorized access.",
	"One of the easiest ways to protect yourself is by using strong passwords.",
	"You should also be careful with suspicious links, emails, and messages.",
	"Now let's put what you've learned into practice."
]

var current_message := 0
var conversation_active := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)

	dialogue = find_dialogue_node(get_tree().current_scene)

	intro_camera = get_tree().current_scene.find_child(
		"IntroCamera",
		true,
		false
	) as Camera3D

	tv_camera_target = get_tree().current_scene.find_child(
		"TVCameraTarget",
		true,
		false
	) as Marker3D


	if dialogue == null:
		push_error("Could not find Dialogue.")
		return

	if intro_camera == null:
		push_error("Could not find IntroCamera.")
		return

	if tv_camera_target == null:
		push_error("Could not find TVCameraTarget.")
		return


	intro_camera.make_current()

	start_conversation(messages)


func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	if not conversation_active:
		return

	if event is InputEventKey:
		if event.pressed and not event.echo:
			if (
				event.keycode == KEY_SPACE
				or event.physical_keycode == KEY_SPACE
			):
				advance_dialogue()


func advance_dialogue() -> void:
	current_message += 1

	if current_message < messages.size():
		dialogue.update_message(messages[current_message])
	else:
		end_conversation()


func start_conversation(new_messages: Array) -> void:
	messages = new_messages
	current_message = 0
	conversation_active = true

	dialogue.show()
	dialogue.update_message(messages[0])


func end_conversation() -> void:
	conversation_active = false
	dialogue.hide()

	move_camera_to_tv()


func move_camera_to_tv() -> void:
	intro_camera.make_current()

	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		intro_camera,
		"global_position",
		tv_camera_target.global_position,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		intro_camera,
		"global_rotation",
		tv_camera_target.global_rotation,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	print("Camera reached TV.")


func find_dialogue_node(node: Node):
	if (
		node.has_method("update_message")
		and node.has_method("message_is_fully_visible")
	):
		return node

	for child in node.get_children():
		var result = find_dialogue_node(child)

		if result != null:
			return result

	return null
