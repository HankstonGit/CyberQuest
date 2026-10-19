extends Node

@onready var tv_menu: CanvasLayer = $TVMenu
@onready var dialogue: CanvasLayer = $Dialogue
@onready var tv_camera: Camera3D = \
	$Level/TVCameraTarget2/TVPreviewCamera
@onready var hover_scam: ColorRect = \
	$TVMenu/HoverScam
@onready var hover_malware: ColorRect = \
	$TVMenu/HoverMalware
@onready var hover_phishing: ColorRect = \
	$TVMenu/HoverPhishing
@onready var hover_social: ColorRect = \
	$TVMenu/HoverSocialEngineering
@onready var scam_button: Button = \
	$TVMenu/BoxContainer/VBoxContainer/Scam
@onready var malware_button: Button = \
	$TVMenu/BoxContainer/VBoxContainer/Malware
@onready var phishing_button: Button = \
	$TVMenu/BoxContainer/VBoxContainer/Phishing
@onready var social_button: Button = \
	$"TVMenu/BoxContainer/VBoxContainer/Social Engineering"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_viewport().mode = (
			Window.MODE_FULLSCREEN
			if get_viewport().mode != Window.MODE_FULLSCREEN
			else Window.MODE_WINDOWED
		)

func _ready() -> void:
	if BattleData.returning_from_battle:
		BattleData.returning_from_battle = false
		show_returning_tv()

func show_returning_tv() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	dialogue.hide()
	tv_camera.make_current()
	tv_menu.show()
	$TVMenu/Background.show()
	$TVMenu/BoxContainer.show()
	$"TVMenu/Welcome!".show()
	$TVMenu/Info.show()
	$TVMenu/UnderWelcome.show()
	$TVMenu/UnderWelcome2.show()
	$TVMenu/RichTextLabel.show()
	$TVMenu/Blink1.hide()
	$TVMenu/Blink2.hide()
	$TVMenu/Blink3.hide()
	$TVMenu/Blink4.hide()
	update_completed_topics()
	setup_tv_focus()

func update_completed_topics() -> void:
	if BattleData.is_topic_completed(
		BattleData.Topic.SCAM
	):
		hover_scam.color = Color.RED
		hover_scam.show()
		scam_button.disabled = true
	if BattleData.is_topic_completed(
		BattleData.Topic.MALWARE
	):
		hover_malware.color = Color.RED
		hover_malware.show()
		malware_button.disabled = true
	if BattleData.is_topic_completed(
		BattleData.Topic.PHISHING
	):
		hover_phishing.color = Color.RED
		hover_phishing.show()
		phishing_button.disabled = true
	if BattleData.is_topic_completed(
		BattleData.Topic.SOCIAL_ENGINEERING
	):
		hover_social.color = Color.RED
		hover_social.show()
		social_button.disabled = true

func setup_tv_focus() -> void:
	scam_button.focus_mode = Control.FOCUS_ALL
	malware_button.focus_mode = Control.FOCUS_ALL
	phishing_button.focus_mode = Control.FOCUS_ALL
	social_button.focus_mode = Control.FOCUS_ALL
	await get_tree().process_frame
	scam_button.grab_focus()

func _on_scam_pressed() -> void:
	BattleData.select_topic(BattleData.Topic.SCAM)
	get_tree().change_scene_to_file("res://main/scenes/stage.tscn")

func _on_malware_pressed() -> void:
	BattleData.select_topic(BattleData.Topic.MALWARE)
	get_tree().change_scene_to_file("res://main/scenes/stage.tscn")

func _on_phishing_pressed() -> void:
	BattleData.select_topic(BattleData.Topic.PHISHING)
	get_tree().change_scene_to_file("res://main/scenes/stage.tscn")

func _on_social_engineering_pressed() -> void:
	BattleData.select_topic(BattleData.Topic.SOCIAL_ENGINEERING)
	get_tree().change_scene_to_file("res://main/scenes/stage.tscn")
