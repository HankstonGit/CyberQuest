extends CharacterBody3D

@export_group("Health")
@export var max_hp: int = 100
var hp: int
var is_dead: bool = false
var is_animating: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hp = max_hp
	animation_player.animation_finished.connect(_on_animation_finished)
	play_idle()

func play_idle() -> void:
	if is_dead or is_animating:
		return
	animation_player.play("E_Idle")

func attack() -> void: # Call this when the Eagle attacks.
	if is_dead:
		return
	is_animating = true
	var attack_animation: String
	if randf() < 0.5:
		attack_animation = "E_Attack_L"
	else:
		attack_animation = "E_Attack_R"
	animation_player.play(attack_animation)

func take_damage(amount: int = 1) -> void: # Call this when a question is answered incorrectly.
	if is_dead:
		return
	hp = maxi(hp - amount, 0)
	if hp <= 0:
		die()
		return
	is_animating = true
	animation_player.play("E_Hurt")

func die() -> void: # Call this when HP reaches zero.
	if is_dead:
		return
	is_dead = true
	is_animating = true
	animation_player.play("E_Death")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "E_Death":
		return
	if is_dead:
		return
	is_animating = false
	play_idle()
