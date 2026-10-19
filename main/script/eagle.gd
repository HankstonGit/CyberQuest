extends Node3D

@export var max_hp: int = 3
var hp: int = 3
var is_dead: bool = false
var is_animating: bool = false
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("battle_ally")
	hp = max_hp
	anim.animation_finished.connect(_on_animation_finished)
	play_idle()

func play_idle() -> void:
	if is_dead or is_animating:
		return
	anim.play("E_Idle")

func attack() -> void:
	if is_dead:
		return
	is_animating = true
	var attack_animation: String = (
		"E_Attack_L" if randf() < 0.5 else "E_Attack_R"
	)
	anim.play(attack_animation)

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	hp = maxi(hp - amount, 0)
	if hp == 0:
		die()
		return
	is_animating = true
	anim.play("E_Hurt")

func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_animating = true
	anim.play("E_Death")

func _on_animation_finished(anim_name: StringName) -> void:
	if is_dead:
		return
	is_animating = false
	play_idle()
