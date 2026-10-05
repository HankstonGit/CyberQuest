extends CanvasLayer

@export var blink_speed: float = 0.12
@export var menu_wait_time: float = 6.0
var sequence_started: bool = false
var topic_buttons: Array[BaseButton] = []
var selected_button: int = -1
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
@onready var scam_button: BaseButton = \
	$BoxContainer/VBoxContainer/Scam
@onready var malware_button: BaseButton = \
	$BoxContainer/VBoxContainer/Malware
@onready var phishing_button: BaseButton = \
	$BoxContainer/VBoxContainer/Phishing
@onready var social_engineering_button: BaseButton = \
	$"BoxContainer/VBoxContainer/Social Engineering"
@onready var hover_scam: ColorRect = $HoverScam
@onready var hover_malware: ColorRect = $HoverMalware
@onready var hover_phishing: ColorRect = $HoverPhishing
@onready var hover_social_engineering: ColorRect = \
	$HoverSocialEngineering
var default_info_text: String = """
[center][font_size=28][b]CYBER SECURITY BASICS[/b][/font_size][/center]
Hover over a topic to learn more.
[center][font_size=18][b]STOP. THINK. VERIFY.[/b][/font_size][/center]
"""
var malware_info: String = """
[font_size=22][b]MALWARE[/b][/font_size]
Malware is malicious software designed to damage, disrupt, spy on, or gain unauthorized access to a computer or network.
Common types include viruses, ransomware, spyware, worms, and trojans.
[b]Warning Signs:[/b]
• Unexpected pop-ups or programs
• Slow computer performance
• Files becoming corrupted or encrypted
• Antivirus software being disabled unexpectedly
[b]Stay Safe:[/b]
Keep your software updated, use trusted antivirus protection, and avoid downloading unknown files or programs.
"""
var social_engineering_info: String = """
[font_size=22][b]SOCIAL ENGINEERING[/b][/font_size]
Social engineering is when an attacker manipulates a person into revealing information or performing an unsafe action.
Instead of attacking a computer directly, the attacker targets human trust, fear, curiosity, or urgency.
[b]Common Tactics:[/b]
• Pretending to be a trusted person or company
• Creating a fake emergency
• Asking for passwords or verification codes
• Offering fake rewards or prizes
[b]Stay Safe:[/b]
Verify who you are communicating with before sharing information. Do not let urgency pressure you into making a quick decision.
"""
var phishing_info: String = """
[font_size=22][b]PHISHING[/b][/font_size]
Phishing is a type of social engineering where attackers send fake emails, messages, or websites designed to steal information.
Attackers may pretend to be banks, schools, employers, delivery companies, or other trusted organizations.
[b]Warning Signs:[/b]
• Suspicious links
• Unexpected attachments
• Misspelled website addresses
• Requests for passwords or personal information
• Messages claiming immediate action is required
[b]Stay Safe:[/b]
Do not click suspicious links. Visit official websites directly and verify unexpected messages through another trusted method.
"""
var scam_info: String = """
[font_size=22][b]SCAMS[/b][/font_size]
A scam is a dishonest scheme designed to trick someone into giving away money, information, accounts, or other valuable resources.
Scams can happen through websites, email, social media, phone calls, text messages, and even online games.
[b]Common Scams:[/b]
• Fake giveaways
• Fake technical support
• Investment scams
• Impersonation scams
• Fake online stores
• Requests for gift cards or unusual payments
[b]Stay Safe:[/b]
Be suspicious of offers that seem too good to be true. Verify the person or organization before sending money or providing personal information.
"""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sequence_started = false
	_hide_blinks()
	_hide_hover_effects()
	_set_menu_visible(false)
	rich_text_label.text = default_info_text
	rich_text_label.bbcode_enabled = true
	rich_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.set_mouse_mode(
		Input.MOUSE_MODE_HIDDEN
	)
	scam_button.mouse_entered.connect(
		_on_scam_hovered
	)
	scam_button.mouse_exited.connect(
		_on_button_exited
	)
	malware_button.mouse_entered.connect(
		_on_malware_hovered
	)
	malware_button.mouse_exited.connect(
		_on_button_exited
	)
	phishing_button.mouse_entered.connect(
		_on_phishing_hovered
	)
	phishing_button.mouse_exited.connect(
		_on_button_exited
	)
	social_engineering_button.mouse_entered.connect(
		_on_social_engineering_hovered
	)
	social_engineering_button.mouse_exited.connect(
		_on_button_exited
	)
	topic_buttons = [
		scam_button,
		malware_button,
		phishing_button,
		social_engineering_button
	]
	for button in topic_buttons:
		button.focus_mode = Control.FOCUS_ALL
		button.focus_entered.connect(
			_on_topic_focus_entered.bind(button)
		)

func _unhandled_input(event: InputEvent) -> void:
	if not sequence_started:
		return

	if not box_container.visible:
		return

	if event.is_action_pressed("move_down") and not event.is_echo():
		_move_topic_focus(1)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("move_up") and not event.is_echo():
		_move_topic_focus(-1)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept") and not event.is_echo():
		var focused: Control = get_viewport().gui_get_focus_owner()

		if focused is BaseButton and focused in topic_buttons:
			get_viewport().set_input_as_handled()
			focused.pressed.emit()

func _move_topic_focus(direction: int) -> void:
	if selected_button == -1:
		if direction > 0:
			selected_button = 0
		else:
			selected_button = topic_buttons.size() - 1
	else:
		selected_button = (
			selected_button
			+ direction
			+ topic_buttons.size()
		) % topic_buttons.size()

	topic_buttons[selected_button].grab_focus()

func _on_topic_focus_entered(button: BaseButton) -> void:
	selected_button = topic_buttons.find(button)
	_hide_hover_effects()
	if button == scam_button:
		hover_scam.show()
		_set_info_text(scam_info)
	elif button == malware_button:
		hover_malware.show()
		_set_info_text(malware_info)
	elif button == phishing_button:
		hover_phishing.show()
		_set_info_text(phishing_info)
	elif button == social_engineering_button:
		hover_social_engineering.show()
		_set_info_text(social_engineering_info)

func start_tv_sequence() -> void:
	if sequence_started:
		return
	sequence_started = true
	_set_menu_visible(false)
	_hide_blinks()
	await get_tree().create_timer(menu_wait_time).timeout
	await _show_blink(blink_1)
	await _show_blink(blink_2)
	await _show_blink(blink_3)
	await _show_blink(blink_4)
	_hide_blinks()
	show_tv_menu()

func _show_blink(blink: ColorRect) -> void:
	_hide_blinks()
	blink.show()
	await get_tree().create_timer(
		blink_speed
	).timeout

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

func _set_info_text(new_text: String) -> void:
	rich_text_label.clear()
	rich_text_label.append_text(new_text)
	rich_text_label.scroll_to_line(0)

func hide_tv_menu() -> void:
	_set_menu_visible(false)
	_hide_blinks()
	_hide_hover_effects()
	Input.set_mouse_mode(
		Input.MOUSE_MODE_HIDDEN
	)

func show_tv_menu() -> void:
	_set_menu_visible(true)
	selected_button = -1
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	_hide_hover_effects()
	_set_info_text(default_info_text)
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE
	)

func _hide_hover_effects() -> void:
	hover_scam.hide()
	hover_malware.hide()
	hover_phishing.hide()
	hover_social_engineering.hide()

func _on_scam_hovered() -> void:
	scam_button.grab_focus()

func _on_malware_hovered() -> void:
	malware_button.grab_focus()

func _on_phishing_hovered() -> void:
	phishing_button.grab_focus()

func _on_social_engineering_hovered() -> void:
	social_engineering_button.grab_focus()

func _on_button_exited() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused == null or focused not in topic_buttons:
		_hide_hover_effects()
		_set_info_text(default_info_text)
