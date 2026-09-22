extends Control

@onready var buttons: Array[Button] = [$VBoxContainer/PlayButton, $VBoxContainer/SettingsButton, $VBoxContainer/QuitButton]
var selected_button: int = 0

func _ready() -> void:
	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_entered.connect(button.grab_focus)
	buttons[selected_button].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down") and not event.is_echo():
		selected_button = (selected_button + 1) % buttons.size()
		buttons[selected_button].grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_up") and not event.is_echo():
		selected_button = (selected_button - 1 + buttons.size()) % buttons.size()
		buttons[selected_button].grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") and not event.is_echo():
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused is Button and focused in buttons:
			get_viewport().set_input_as_handled() # Handle before scene change
			focused.pressed.emit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_settings_button_pressed() -> void:
	return

func _on_quit_button_pressed() -> void:
	get_tree().quit()
