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
