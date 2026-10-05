extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_viewport().mode = (
			Window.MODE_FULLSCREEN
			if get_viewport().mode != Window.MODE_FULLSCREEN
			else Window.MODE_WINDOWED
		)

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
