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
@onready var victory_label: Label = $Victory
@onready var defeat_label: Label = $Defeat
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
	player_hp -= 1
	player_health.value = player_hp
	show_answer_result(index, false)
	update_health_ui()
	if wrong_answers >= 3:
		lose_battle()
		return
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
	victory_label.show()
	BattleData.clear_selected_topic()

func lose_battle() -> void:
	battle_finished = true
	disable_answers()
	player_hp = 0
	player_health.value = 0
	update_health_ui()
	defeat_label.show()

func disable_answers() -> void:
	for button in answer_buttons:
		button.disabled = true

func get_scam_questions() -> Array[Dictionary]:
	return [
		{
			"question": "Which is a common sign of a scam?",
			"answers": [
				"A request for gift cards",
				"A normal software update",
				"A strong password",
				"A trusted bookmark"
			],
			"correct": 0
		},
		{
			"question": "What should you do if an offer seems too good to be true?",
			"answers": [
				"Send money quickly",
				"Verify the person or company",
				"Give them your password",
				"Ignore all security warnings"
			],
			"correct": 1
		},
		{
			"question": "Which payment request can be a scam warning sign?",
			"answers": [
				"Gift cards",
				"Normal checkout",
				"School lunch card",
				"Library card"
			],
			"correct": 0
		},
		{
			"question": "Where can scams happen?",
			"answers": [
				"Only through email",
				"Only on websites",
				"Only through phone calls",
				"Through many different methods"
			],
			"correct": 3
		},
		{
			"question": "What is an impersonation scam?",
			"answers": [
				"Someone pretending to be a trusted person",
				"Updating antivirus software",
				"Creating a strong password",
				"Restarting a computer"
			],
			"correct": 0
		},
		{
			"question": "What should you do before sending money online?",
			"answers": [
				"Verify who you are sending it to",
				"Disable antivirus",
				"Share your password",
				"Click every link"
			],
			"correct": 0
		}
	]


func get_malware_questions() -> Array[Dictionary]:
	return [
		{
			"question": "What is malware?",
			"answers": [
				"Malicious software",
				"A safe website",
				"A strong password",
				"A computer monitor"
			],
			"correct": 0
		},
		{
			"question": "Which is a type of malware?",
			"answers": [
				"Firewall",
				"Ransomware",
				"Keyboard",
				"Router"
			],
			"correct": 1
		},
		{
			"question": "Which can be a warning sign of malware?",
			"answers": [
				"Unexpected pop-ups",
				"A normal login",
				"Using two-factor authentication",
				"Updating software"
			],
			"correct": 0
		},
		{
			"question": "What can ransomware do?",
			"answers": [
				"Encrypt your files",
				"Improve performance",
				"Create strong passwords",
				"Block suspicious links"
			],
			"correct": 0
		},
		{
			"question": "How can you reduce malware risk?",
			"answers": [
				"Download unknown files",
				"Keep software updated",
				"Disable antivirus",
				"Ignore security warnings"
			],
			"correct": 1
		},
		{
			"question": "What can spyware do?",
			"answers": [
				"Secretly collect information",
				"Repair damaged hardware",
				"Improve internet speed",
				"Create backups"
			],
			"correct": 0
		}
	]


func get_phishing_questions() -> Array[Dictionary]:
	return [
		{
			"question": "What is phishing?",
			"answers": [
				"A fake message designed to steal information",
				"A type of antivirus",
				"A safe login method",
				"A computer update"
			],
			"correct": 0
		},
		{
			"question": "Which is a phishing warning sign?",
			"answers": [
				"A suspicious link",
				"A normal bookmark",
				"A secure password",
				"Updated software"
			],
			"correct": 0
		},
		{
			"question": "What should you do with a suspicious link?",
			"answers": [
				"Click it immediately",
				"Do not click it",
				"Send your password",
				"Disable antivirus"
			],
			"correct": 1
		},
		{
			"question": "Attackers may pretend to be which of these?",
			"answers": [
				"Banks or employers",
				"Only video games",
				"Only antivirus programs",
				"Only friends"
			],
			"correct": 0
		},
		{
			"question": "What should you check before entering login information?",
			"answers": [
				"The website address",
				"Your screen brightness",
				"Your speaker volume",
				"Your wallpaper"
			],
			"correct": 0
		},
		{
			"question": "What is a safer way to visit your bank website?",
			"answers": [
				"Use a suspicious email link",
				"Type the official address directly",
				"Use any pop-up",
				"Click an unknown advertisement"
			],
			"correct": 1
		}
	]


func get_social_engineering_questions() -> Array[Dictionary]:
	return [
		{
			"question": "What does social engineering target?",
			"answers": [
				"Human trust and behavior",
				"Only computer hardware",
				"Only internet speed",
				"Only software updates"
			],
			"correct": 0
		},
		{
			"question": "Which is a social engineering tactic?",
			"answers": [
				"Creating fake urgency",
				"Installing updates",
				"Using strong passwords",
				"Backing up files"
			],
			"correct": 0
		},
		{
			"question": "What should you do before sharing sensitive information?",
			"answers": [
				"Verify who you are talking to",
				"Share it immediately",
				"Disable antivirus",
				"Ignore warning signs"
			],
			"correct": 0
		},
		{
			"question": "Why do attackers create fake emergencies?",
			"answers": [
				"To pressure people into acting quickly",
				"To improve computer speed",
				"To update software",
				"To protect accounts"
			],
			"correct": 0
		},
		{
			"question": "What information should you be careful sharing?",
			"answers": [
				"Passwords and verification codes",
				"Your favorite color",
				"Your screen resolution",
				"Your game volume"
			],
			"correct": 0
		},
		{
			"question": "What is the safest response to unexpected pressure?",
			"answers": [
				"Stop and verify the request",
				"Act immediately",
				"Send your password",
				"Click every link"
			],
			"correct": 0
		}
	]
