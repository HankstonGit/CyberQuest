extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	resume_button.pressed.connect(_resume)
	quit_button.pressed.connect(_quit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			_resume()
		else:
			_pause()

func _pause() -> void:
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func _resume() -> void:
	get_tree().paused = false
	hide()

func _quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/scenes/main_menu.tscn")
