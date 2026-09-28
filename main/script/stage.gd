extends Node3D 
 
const SOPHIA_SCENE: PackedScene = preload( 
	"res://main/player/sophia_skin/sophia_skin.tscn" 
) 
const CYBERPEST_SCENE: PackedScene = preload(
	"res://main/characters/cyber_pest.tscn"
)

@onready var fighters: Node3D = $Fighters 
@onready var player_spawn: Marker3D = $Spawns/Player 
@onready var ally_spawn: Marker3D = $"Spawns/CyberPet(Ally)" 
@onready var enemy_spawn: Marker3D = $"Spawns/CyberPest(Enemy)" 
@onready var camera_behind: Camera3D = $CameraAngles/CameraBehind 
@onready var camera_enemy: Camera3D = $CameraAngles/CameraEnemyAngle 
@onready var camera_full: Camera3D = $CameraAngles/CameraFull 
@export var camera_switch_time: float = 5.0 
@export var camera_move_distance: float = 0.5
@export var camera_move_speed: float = 0.4
 
var battle_cameras: Array[Camera3D] = [] 
var current_camera_index: int = 0 
var camera_start_positions: Array[Vector3] = []
var camera_move_time: float = 0.0 
 
func _ready() -> void: 
	spawn_battle() 
	setup_cameras() 
 
func _process(delta: float) -> void:
	if battle_cameras.is_empty():
		return
	
	camera_move_time += delta * camera_move_speed
	
	var camera = battle_cameras[current_camera_index]
	var start_position = camera_start_positions[current_camera_index]
	
	camera.position.x = start_position.x + sin(camera_move_time) * camera_move_distance

func spawn_battle() -> void: 
	var sophia = SOPHIA_SCENE.instantiate() 
	fighters.add_child(sophia) 
	sophia.global_transform = player_spawn.global_transform 
	
	if BattleData.ally_scene: # CYBERPET ALLY
		var ally = BattleData.ally_scene.instantiate() 
		fighters.add_child(ally) 
		ally.global_transform = ally_spawn.global_transform 
	else: 
		push_error("GenericStage: No CyberPet ally selected!") 
	
	var enemy = CYBERPEST_SCENE.instantiate() # CYBERPEST ENEMY
	fighters.add_child(enemy)
	enemy.global_transform = enemy_spawn.global_transform
 
func setup_cameras() -> void: 
	battle_cameras = [ 
		camera_behind, 
		camera_enemy, 
		camera_full 
	] 
	camera_start_positions = [
		camera_behind.position,
		camera_enemy.position,
		camera_full.position
	]
	camera_full.make_current() # Start with the full battlefield shot. 
	current_camera_index = 2 
	camera_cycle() # Start automatic switching for testing. 
 
func camera_cycle() -> void: 
	while true: 
		await get_tree().create_timer(camera_switch_time).timeout 
		switch_to_next_camera() 
 
func switch_to_next_camera() -> void:
	var old_camera = battle_cameras[current_camera_index]
	old_camera.position = camera_start_positions[current_camera_index]
	current_camera_index += 1 
	if current_camera_index >= battle_cameras.size(): 
		current_camera_index = 0 
	camera_move_time = 0.0
	battle_cameras[current_camera_index].make_current() 
 
func show_player_side() -> void: 
	camera_behind.make_current() 
func show_enemy_side() -> void: 
	camera_enemy.make_current() 
func show_full_battle() -> void: 
	camera_full.make_current()
