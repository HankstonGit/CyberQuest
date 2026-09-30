extends Node

@onready var dialogue = $Dialogue
@onready var tv_menu = $TVMenu

var dialogue_lines: Array[String] = [
	"Welcome to CyberQuest.",
	"Before we begin, you need to understand a few important cyber security topics.",
	"Use the terminal to learn about Malware, Social Engineering, Phishing, and Scams.",
	"Select a topic when you're ready."
]

var current_dialogue_index: int = 0
var dialogue_finished: bool = false


func _ready() -> void:
	dialogue.message_completed.connect(_on_dialogue_message_completed)

	tv_menu.hide_tv_menu()

	_start_dialogue()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_viewport().mode = (
			Window.MODE_FULLSCREEN
			if get_viewport().mode != Window.MODE_FULLSCREEN
			else Window.MODE_WINDOWED
		)


func _start_dialogue() -> void:
	dialogue_finished = false
	current_dialogue_index = 0

	dialogue.show()

	if dialogue_lines.is_empty():
		_finish_dialogue()
		return

	dialogue.update_message(dialogue_lines[current_dialogue_index])


func _on_dialogue_message_completed() -> void:
	if dialogue_finished:
		return

	current_dialogue_index += 1

	if current_dialogue_index < dialogue_lines.size():
		dialogue.update_message(dialogue_lines[current_dialogue_index])
	else:
		_finish_dialogue()


func _finish_dialogue() -> void:
	if dialogue_finished:
		return

	dialogue_finished = true

	dialogue.hide()

	tv_menu.start_tv_sequence()
