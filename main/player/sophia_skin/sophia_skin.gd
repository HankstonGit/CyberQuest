class_name SophiaSkin extends Node3D

@onready var animation_player: AnimationPlayer = $sophia/AnimationPlayer

var current_animation: String = ""
var run_tilt: float = 0.0 : set = _set_run_tilt


func _ready():
	_set_animation_loops()
	idle()


func _set_animation_loops():
	animation_player.get_animation("Idle_003").loop_mode = Animation.LOOP_LINEAR
	animation_player.get_animation("Run_003").loop_mode = Animation.LOOP_LINEAR


func _play_animation(animation_name: String):
	if current_animation == animation_name and animation_player.is_playing():
		return

	current_animation = animation_name
	animation_player.play(animation_name)


func _set_run_tilt(value: float):
	run_tilt = clamp(value, -1.0, 1.0)


func idle():
	_play_animation("Idle_003")


func move():
	_play_animation("Run_003")


func fall():
	_play_animation("Fall_003")


func jump():
	_play_animation("Jump_003")


func edge_grab():
	_play_animation("EdgeGrab_001")


func wall_slide():
	_play_animation("WallSlide_003")
