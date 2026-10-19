extends CanvasLayer

@onready var enemy_name: Label = $BattlePanel/EnemyName
@onready var enemy_hp: ProgressBar = $BattlePanel/EnemyHealth
@onready var topic_label: Label = $BattlePanel/Topic
@onready var player_health: ProgressBar = \
	$BattlePanel/PlayerHealth
@onready var player_health_text: Label = \
	$BattlePanel/PlayerHealthText
@onready var question_label: Label = \
	$BattlePanel/QuestionPanel
@onready var answer_1: Button = \
	$BattlePanel/Answers/Button
@onready var answer_2: Button = \
	$BattlePanel/Answers/Button2
@onready var answer_3: Button = \
	$BattlePanel/Answers/Button3
@onready var answer_4: Button = \
	$BattlePanel/Answers/Button4
@onready var lost_battle_noise: AudioStreamPlayer = $"../LostBattleNoise"
@onready var warning_noise: AudioStreamPlayer = $"../WarningNoise"
@onready var fail_game_noise: AudioStreamPlayer = $"../FailGameNoise"
@onready var victory_label: Label = $Victory
@onready var defeat_label: Label = $Defeat
@onready var beat: ColorRect = $Beat
@onready var answer_preview: Label = $BattlePanel/AnswerPreview
var answer_buttons: Array[Button] = []
var player_hp: int = 3
var enemy_hp_value: int = 6
var correct_answers: int = 0
var wrong_answers: int = 0
var current_question_index: int = 0
var correct_answer_index: int = 0
var battle_finished: bool = false
var questions: Array[Dictionary] = []
var current_answers: Array[String] = []
func _ready() -> void:
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE
	)
	answer_buttons = [
		answer_1,
		answer_2,
		answer_3,
		answer_4
	]
	answer_1.pressed.connect(
		_on_answer_pressed.bind(0)
	)
	answer_2.pressed.connect(
		_on_answer_pressed.bind(1)
	)
	answer_3.pressed.connect(
		_on_answer_pressed.bind(2)
	)
	answer_4.pressed.connect(
		_on_answer_pressed.bind(3)
	)
	answer_1.mouse_entered.connect(
		_on_answer_hovered.bind(0)
	)
	answer_2.mouse_entered.connect(
		_on_answer_hovered.bind(1)
	)
	answer_3.mouse_entered.connect(
		_on_answer_hovered.bind(2)
	)
	answer_4.mouse_entered.connect(
		_on_answer_hovered.bind(3)
	)
	answer_1.mouse_exited.connect(
		_on_answer_exited
	)
	answer_2.mouse_exited.connect(
		_on_answer_exited
	)
	answer_3.mouse_exited.connect(
		_on_answer_exited
	)
	answer_4.mouse_exited.connect(
		_on_answer_exited
	)
	victory_label.hide()
	defeat_label.hide()
	beat.hide()
	setup_battle()

func _on_answer_hovered(index: int) -> void:
	if index < 0 or index >= current_answers.size():
		return
	answer_preview.text = current_answers[index]

func _on_answer_exited() -> void:
	answer_preview.text = ""

func setup_battle() -> void:
	player_hp = 3
	enemy_hp_value = 6
	correct_answers = 0
	wrong_answers = 0
	current_question_index = 0
	battle_finished = false
	player_health.max_value = 3
	player_health.value = player_hp
	enemy_hp.max_value = 6
	enemy_hp.value = enemy_hp_value
	enemy_name.text = "CyberPest"
	load_topic_questions()
	update_health_ui()
	show_question()

func load_topic_questions() -> void:
	match BattleData.selected_topic:
		BattleData.Topic.SCAM:
			topic_label.text = "SCAMS"
			questions = get_scam_questions()
		BattleData.Topic.MALWARE:
			topic_label.text = "MALWARE"
			questions = get_malware_questions()
		BattleData.Topic.PHISHING:
			topic_label.text = "PHISHING"
			questions = get_phishing_questions()
		BattleData.Topic.SOCIAL_ENGINEERING:
			topic_label.text = "SOCIAL ENGINEERING"
			questions = get_social_engineering_questions()
		_:
			topic_label.text = "UNKNOWN"
			questions = []

func show_question() -> void:
	if battle_finished:
		return
	if questions.is_empty():
		push_error("BattleUI: No questions loaded.")
		return
	if current_question_index >= questions.size():
		current_question_index = 0
	var question: Dictionary = \
		questions[current_question_index]
	question_label.text = question["question"]
	current_answers.clear()
	for answer in question["answers"]:
		current_answers.append(str(answer))
	answer_buttons[0].text = "Option A"
	answer_buttons[1].text = "Option B"
	answer_buttons[2].text = "Option C"
	answer_buttons[3].text = "Option D"
	answer_preview.text = ""
	correct_answer_index = question["correct"]
	reset_answer_colors()

func _on_answer_pressed(index: int) -> void:
	if battle_finished:
		return
	if index == correct_answer_index:
		handle_correct_answer(index)
	else:
		handle_wrong_answer(index)

func handle_correct_answer(index: int) -> void:
	correct_answers += 1
	var ally = get_battle_ally()
	if ally:
		ally.attack()
	enemy_hp_value -= 1
	enemy_hp.value = enemy_hp_value
	show_answer_result(index, true)
	if correct_answers >= 6:
		win_battle()
		return
	await get_tree().create_timer(0.8).timeout
	next_question()


func handle_wrong_answer(index: int) -> void:
	wrong_answers += 1
	player_hp = maxi(player_hp - 1, 0)
	var ally = get_battle_ally()
	if ally:
		ally.take_damage(1)
	player_health.value = player_hp
	show_answer_result(index, false)
	update_health_ui()
	if player_hp <= 0: # HP reached zero: play the fail sound immediately.
		lost_battle_noise.stop()
		warning_noise.stop()
		fail_game_noise.stop()
		fail_game_noise.play()
		lose_battle()
		return
	lost_battle_noise.stop() 	# Play the damage sound on non-lethal hits.
	lost_battle_noise.play() 	# Warn the player when only 1 HP remains.
	if player_hp == 1:
		warning_noise.stop()
		warning_noise.play()
	await get_tree().create_timer(0.8).timeout
	next_question()

func next_question() -> void:
	current_question_index += 1
	if current_question_index >= questions.size():
		current_question_index = 0
	show_question()

func update_health_ui() -> void:
	player_health_text.text = \
		"HP: " + str(player_hp) + " / 3"

func show_answer_result(
	index: int,
	was_correct: bool
) -> void:
	reset_answer_colors()
	if was_correct:
		answer_buttons[index].modulate = Color.GREEN
	else:
		answer_buttons[index].modulate = Color.RED
		answer_buttons[
			correct_answer_index
		].modulate = Color.GREEN

func reset_answer_colors() -> void:
	for button in answer_buttons:
		button.modulate = Color.WHITE

func win_battle() -> void:
	battle_finished = true
	disable_answers()
	enemy_hp_value = 0
	enemy_hp.value = 0
	beat.show()
	victory_label.show()
	victory_label.move_to_front()
	BattleData.complete_topic(
		BattleData.selected_topic
	)
	await get_tree().create_timer(5.0).timeout
	BattleData.clear_selected_topic()
	BattleData.return_to_tv()

func lose_battle() -> void:
	battle_finished = true
	disable_answers()
	player_hp = 0
	player_health.value = 0
	update_health_ui()
	await get_tree().create_timer(3.0).timeout # Give the Eagle time to show its death animation.
	beat.show() # Now show the defeat menu.
	defeat_label.show()
	defeat_label.move_to_front()
	await get_tree().create_timer(5.0).timeout # Keep the defeat menu visible before returning to the TV.
	BattleData.clear_selected_topic()
	BattleData.return_to_tv()

func disable_answers() -> void:
	for button in answer_buttons:
		button.disabled = true

func get_battle_ally() -> Node:
	return get_tree().get_first_node_in_group("battle_ally")

func get_scam_questions() -> Array[Dictionary]:
	return [
		{
			"question": "A Hookling offers 100 free sparkle gems if you tell it your game password. What should you do?",
			"answers": [
				"Never share your password for rewards.",
				"Share your password to get the gems.",
				"Send your password only if the prize looks real.",
				"Ask the Hookling to keep your password secret."
			],
			"correct": 0
		},
		{
			"question": "A Hookling says you won a VIP badge and asks for your email and secret code. What is the safest choice?",
			"answers": [
				"Type your email and secret code to claim the badge.",
				"Ignore the message and tell a trusted grown-up.",
				"Send only the secret code.",
				"Click the message again to see if the prize is real."
			],
			"correct": 1
		},
		{
			"question": "A pop-up promises a rare critter if you enter your parent's phone number. What should you do?",
			"answers": [
				"Enter the number to spin the wheel.",
				"Use a friend's phone number instead.",
				"Keep phone numbers private.",
				"Enter the number only if the wheel looks fun."
			],
			"correct": 2
		},
		{
			"question": "A message offers unlimited coins but asks for your username and password to activate a secret gift code. What should you do?",
			"answers": [
				"Send your username and password to get the coins.",
				"Share the password if the code is secret.",
				"Try the code first, then decide.",
				"Don't share usernames or passwords for rewards."
			],
			"correct": 3
		}
	]


func get_malware_questions() -> Array[Dictionary]:
	return [
		{
			"question": "A Malware Mite says your tablet is broken and tells you to click a link right now. What should you do?",
			"answers": [
				"Close the pop-up and ask a grown-up for help.",
				"Click the link before the countdown ends.",
				"Download whatever the pop-up recommends.",
				"Give the pop-up permission to fix the tablet."
			],
			"correct": 0
		},
		{
			"question": "A strange file named super_song_FREE.exe promises a secret song. What should you do?",
			"answers": [
				"Download it because free songs are fun.",
				"Only download music from the real game store.",
				"Open it to check what it does.",
				"Share it with friends to see if it works."
			],
			"correct": 1
		},
		{
			"question": "A Malware Mite offers an unfamiliar Super Speed Booster for your slow device. What is the safest choice?",
			"answers": [
				"Install it because it promises to help.",
				"Install it and ignore any warnings.",
				"Use the real settings menu to check for updates.",
				"Give it access to everything on the device."
			],
			"correct": 2
		},
		{
			"question": "An unknown emoji pack asks for storage and camera permissions. What should you do?",
			"answers": [
				"Install it because the emojis look cool.",
				"Allow every permission it asks for.",
				"Install it first and check permissions later.",
				"Don't give permissions to unknown downloads."
			],
			"correct": 3
		}
	]


func get_phishing_questions() -> Array[Dictionary]:
	return [
		{
			"question": "A poster shows a glowing QR code that says 'Scan me for a surprise!' What should you do?",
			"answers": [
				"Ask a trusted grown-up before scanning an unknown code.",
				"Scan any QR code because it is always safe.",
				"Scan it and enter any information it requests.",
				"Share the code with friends so they can try it."
			],
			"correct": 0
		},
		{
			"question": "A login page offers 50 bonus coins, but its logo looks slightly wrong. What should you do?",
			"answers": [
				"Log in because it promises rewards.",
				"Only log in through the real game app or website.",
				"Enter your password to check whether it works.",
				"Use the same password and secret code."
			],
			"correct": 1
		},
		{
			"question": "A message says someone wants to be your friend and sends a strange link. What should you do?",
			"answers": [
				"Open it because friend requests are safe.",
				"Enter your login details to see who it is.",
				"Don't tap unknown links; they may be phishing.",
				"Forward the link to everyone you know."
			],
			"correct": 2
		},
		{
			"question": "A message says you must install a special game update using a link that doesn't match the real update icon. What should you do?",
			"answers": [
				"Tap it because every update message is safe.",
				"Install it before the message disappears.",
				"Enter your password to approve the update.",
				"Get updates from the official app store or settings."
			],
			"correct": 3
		}
	]


func get_social_engineering_questions() -> Array[Dictionary]:
	return [
		{
			"question": "A stranger offers a rare creature if you tell them your home address. What should you do?",
			"answers": [
				"Keep your address private.",
				"Share your address to get the rare creature.",
				"Give only your street name.",
				"Share it if the trade sounds fair."
			],
			"correct": 0
		},
		{
			"question": "A game app suddenly asks to use your camera. What is the safest response?",
			"answers": [
				"Always allow camera access without checking.",
				"Only allow permission when you understand why the app needs it.",
				"Allow it because every app needs a camera.",
				"Give permission and ask questions later."
			],
			"correct": 1
		},
		{
			"question": "Someone claiming to be your school friend messages you and says not to tell anyone. What should you remember?",
			"answers": [
				"It's okay to keep secrets if they say they're a friend.",
				"Send them private information to prove you're friends.",
				"Keeping secrets for online strangers is unsafe.",
				"Never tell a trusted adult about online messages."
			],
			"correct": 2
		},
		{
			"question": "A familiar-looking character urgently demands your account name and pressures you to respond fast. What should you do?",
			"answers": [
				"Send your account name right away to help.",
				"Respond quickly so the character doesn't get upset.",
				"Share account details if the character looks familiar.",
				"Pause and think before responding."
			],
			"correct": 3
		}
	]
