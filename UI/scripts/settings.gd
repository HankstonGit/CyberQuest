extends Control

@onready var resume_button: Button = $BlackOutline5/BlackOutline
@onready var quit_button: Button = $BlackOutline5/BlackOutline2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	resume_button.pressed.connect(_resume)
	quit_button.pressed.connect(_quit)

func _resume() -> void:
	$MenuButton.play(0.8)
	var stage = get_parent().get_parent()
	if stage.has_method("toggle_pause"):
		stage.toggle_pause()

func _quit() -> void:
	get_tree().paused = false
	$MenuButton.play(0.8)
	get_tree().change_scene_to_file("res://UI/scenes/main_menu.tscn")
