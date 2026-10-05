extends CanvasLayer

signal message_completed

@onready var content: RichTextLabel = $Content
@onready var type_timer: Timer = $TypeTimer
@onready var pause_timer: Timer = $PauseTimer
@onready var pause_calculator = $PauseCalculator

var message_active: bool = false
var message_finished_emitted: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	type_timer.timeout.connect(_on_type_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	pause_calculator.pause_requested.connect(_on_pause_requested)


func update_message(message: String) -> void:
	type_timer.stop()
	pause_timer.stop()

	message_active = true
	message_finished_emitted = false

	var clean_message = pause_calculator.extract_pauses_from_string(message)

	content.text = clean_message
	content.visible_characters = 0

	type_timer.start()


func _input(event: InputEvent) -> void:
	if not message_active:
		return

	var advance_pressed: bool = false

	if event.is_action_pressed("jump"):
		advance_pressed = true

	if event.is_action_pressed("left_click"):
		advance_pressed = true

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			advance_pressed = true

	if not advance_pressed:
		return

	_handle_dialogue_input()
	get_viewport().set_input_as_handled()


func _handle_dialogue_input() -> void:
	if not message_is_fully_visible():
		show_full_message()
	else:
		_finish_message()


func show_full_message() -> void:
	type_timer.stop()
	pause_timer.stop()

	content.visible_characters = content.get_total_character_count()


func _finish_message() -> void:
	if message_finished_emitted:
		return

	message_finished_emitted = true
	message_active = false

	type_timer.stop()
	pause_timer.stop()

	message_completed.emit()


func message_is_fully_visible() -> bool:
	return content.visible_characters >= content.get_total_character_count()


func _on_type_timer_timeout() -> void:
	if content.visible_characters < content.get_total_character_count():
		content.visible_characters += 1

		pause_calculator.check_at_position(
			content.visible_characters
		)

	if content.visible_characters >= content.get_total_character_count():
		type_timer.stop()


func _on_pause_requested(duration: float) -> void:
	if message_is_fully_visible():
		return

	type_timer.stop()
	pause_timer.start(duration)


func _on_pause_timer_timeout() -> void:
	if not message_is_fully_visible():
		type_timer.start()
