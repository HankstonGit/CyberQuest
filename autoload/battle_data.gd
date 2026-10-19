extends Node

var ally_scene: PackedScene = null # The CyberPet currently fighting alongside the player
var enemy_scene: PackedScene = null # The actual enemy being fought
enum Topic {
	NONE,
	SCAM,
	MALWARE,
	PHISHING,
	SOCIAL_ENGINEERING
}
var selected_topic: Topic = Topic.NONE
var scam_cleared: bool = false
var malware_cleared: bool = false
var phishing_cleared: bool = false
var social_engineering_cleared: bool = false
var completed_topics: Dictionary = {}
var returning_from_battle: bool = false

func complete_topic(topic: Topic) -> void:
	completed_topics[topic] = true

func is_topic_completed(topic: Topic) -> bool:
	return completed_topics.get(topic, false)

func return_to_tv() -> void:
	returning_from_battle = true
	get_tree().paused = false
	get_tree().change_scene_to_file(
		"res://main/scenes/game.tscn"
	)

func select_topic(topic: Topic) -> void:
	selected_topic = topic

func clear_selected_topic() -> void:
	match selected_topic:
		Topic.SCAM:
			scam_cleared = true
		Topic.MALWARE:
			malware_cleared = true
		Topic.PHISHING:
			phishing_cleared = true
		Topic.SOCIAL_ENGINEERING:
			social_engineering_cleared = true

func is_topic_cleared(topic: Topic) -> bool:
	match topic:
		Topic.SCAM:
			return scam_cleared
		Topic.MALWARE:
			return malware_cleared
		Topic.PHISHING:
			return phishing_cleared
		Topic.SOCIAL_ENGINEERING:
			return social_engineering_cleared
	return false
