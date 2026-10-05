extends Node

@onready var dialogue = $"../Dialogue"
@onready var intro_camera: Camera3D = \
	$"../Level/IntroCamera2"
@onready var tv_camera: Camera3D = \
	$"../Level/TVCameraTarget2/TVPreviewCamera"
@onready var tv_menu = $"../TVMenu"
@onready var intro_controller = $"../Level/IntroController2"

var messages: Array[String] = [
	"Welcome to CyberQuest.",
	"Before we begin, let's go over some cybersecurity basics.",
	"Cybersecurity is about protecting devices, accounts, and information from unauthorized access.",
	"One of the easiest ways to protect yourself is by using strong passwords.",
	"You should also be careful with suspicious links, emails, and messages.",
	"Now let's put what you've learned into practice."
]
var current_message: int = 0
var conversation_active: bool = false
var ending_sequence_started: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dialogue.message_completed.connect(
		_on_dialogue_message_completed
	)
	tv_menu.hide_tv_menu()
	intro_camera.make_current()
	start_conversation(messages)

func _on_dialogue_message_completed() -> void:
	if not conversation_active:
		return
	advance_dialogue()

func advance_dialogue() -> void:
	current_message += 1
	if current_message < messages.size():
		dialogue.update_message(
			messages[current_message]
		)
	else:
		end_conversation()

func start_conversation(
	new_messages: Array[String]
) -> void:
	if new_messages.is_empty():
		return
	messages = new_messages
	current_message = 0
	conversation_active = true
	ending_sequence_started = false
	dialogue.show()
	dialogue.update_message(
		messages[current_message]
	)

func end_conversation() -> void:
	if ending_sequence_started:
		return

	ending_sequence_started = true
	conversation_active = false

	dialogue.hide()

	print("Dialogue finished.")

	await intro_controller.move_camera_to_tv()

	print("Camera zoom finished.")

	await get_tree().create_timer(0.3).timeout

	print("Starting TV menu.")

	tv_menu.start_tv_sequence()
