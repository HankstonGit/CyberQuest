extends CanvasLayer

@export var dialogue_controller: Node
@export var blink_speed: float = 0.12

var sequence_started: bool = false

@onready var blink_1: ColorRect = $Blink1
@onready var blink_2: ColorRect = $Blink2
@onready var blink_3: ColorRect = $Blink3
@onready var blink_4: ColorRect = $Blink4
@onready var background = $Background
@onready var box_container = $BoxContainer
@onready var welcome = $"Welcome!"
@onready var info = $Info
@onready var under_welcome_2 = $UnderWelcome2
@onready var under_welcome = $UnderWelcome
@onready var rich_text_label = $RichTextLabel
@onready var scam_button: BaseButton = $BoxContainer/VBoxContainer/Scam
@onready var malware_button: BaseButton = $BoxContainer/VBoxContainer/Malware
@onready var phishing_button: BaseButton = $BoxContainer/VBoxContainer/Phishing
@onready var social_engineering_button: BaseButton = $"BoxContainer/VBoxContainer/Social Engineering"
@onready var hover_scam: ColorRect = $HoverScam
@onready var hover_malware: ColorRect = $HoverMalware
@onready var hover_phishing: ColorRect = $HoverPhishing
@onready var hover_social_engineering: ColorRect = $HoverSocialEngineering

func _ready() -> void:
	_hide_blinks()
	_hide_hover_effects()
	_set_menu_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if dialogue_controller:
		dialogue_controller.dialogue_completed.connect(_on_dialogue_completed)
	scam_button.mouse_entered.connect(_on_scam_hovered)
	scam_button.mouse_exited.connect(_on_button_exited)
	malware_button.mouse_entered.connect(_on_malware_hovered)
	malware_button.mouse_exited.connect(_on_button_exited)
	phishing_button.mouse_entered.connect(_on_phishing_hovered)
	phishing_button.mouse_exited.connect(_on_button_exited)
	social_engineering_button.mouse_entered.connect(_on_social_engineering_hovered)
	social_engineering_button.mouse_exited.connect(_on_button_exited)

func _on_dialogue_completed() -> void:
	start_tv_sequence()

func start_tv_sequence() -> void:
	if sequence_started:
		return
	sequence_started = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_set_menu_visible(false)
	_hide_blinks()
	await _show_blink(blink_1)
	await _show_blink(blink_2)
	await _show_blink(blink_3)
	await _show_blink(blink_4)
	_hide_blinks()
	_set_menu_visible(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _show_blink(blink: ColorRect) -> void:
	_hide_blinks()
	blink.show()
	await get_tree().create_timer(blink_speed).timeout

func _hide_blinks() -> void:
	blink_1.hide()
	blink_2.hide()
	blink_3.hide()
	blink_4.hide()

func _set_menu_visible(value: bool) -> void:
	background.visible = value
	box_container.visible = value
	welcome.visible = value
	info.visible = value
	under_welcome_2.visible = value
	under_welcome.visible = value
	rich_text_label.visible = value
	if not value:
		_hide_hover_effects()

func _hide_hover_effects() -> void:
	hover_scam.hide()
	hover_malware.hide()
	hover_phishing.hide()
	hover_social_engineering.hide()

func _on_scam_hovered() -> void:
	_hide_hover_effects()
	hover_scam.show()

func _on_malware_hovered() -> void:
	_hide_hover_effects()
	hover_malware.show()

func _on_phishing_hovered() -> void:
	_hide_hover_effects()
	hover_phishing.show()

func _on_social_engineering_hovered() -> void:
	_hide_hover_effects()
	hover_social_engineering.show()

func _on_button_exited() -> void:
	_hide_hover_effects()
