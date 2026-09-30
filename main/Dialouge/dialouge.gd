extends Control

signal message_completed

@onready var content: RichTextLabel = $Content
@onready var type_timer: Timer = $TypeTimer
@onready var pause_timer: Timer = $PauseTimer
@onready var pause_calculator = $PauseCalculator


func _ready() -> void:
	type_timer.timeout.connect(_on_type_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	pause_calculator.pause_requested.connect(_on_pause_requested)


func update_message(message: String) -> void:
	type_timer.stop()
	pause_timer.stop()

	var clean_message = pause_calculator.extract_pauses_from_string(message)

	content.text = clean_message
	content.visible_characters = 0

	type_timer.start()


func message_is_fully_visible() -> bool:
	return content.visible_characters >= content.get_total_character_count()


func _on_type_timer_timeout() -> void:
	if content.visible_characters < content.get_total_character_count():
		content.visible_characters += 1

		pause_calculator.check_at_position(
			content.visible_characters
		)
	else:
		type_timer.stop()
		message_completed.emit()


func _on_pause_requested(duration: float) -> void:
	type_timer.stop()
	pause_timer.start(duration)


func _on_pause_timer_timeout() -> void:
	if not message_is_fully_visible():
		type_timer.start()
