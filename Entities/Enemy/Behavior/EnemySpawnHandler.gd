extends Node3D

signal spawn_enemy(enemy : Enemy, spawn_position: Vector3)

@export var enemy_scene : PackedScene
@export var decoy_scene : PackedScene

@export_range(1,5,1) var max_enemies : int = 1
@export_range(0.01,1,0.01) var chance_to_spawn : float = 0.25

@onready var timer : Timer = $Timer

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var active : bool = true : set = set_spawner_active

var enemy_spawned_count : int = 0

func _ready() -> void:
	randomize()
	
func enemy_is_running_after() -> void:
	active = false
	
func set_spawner_active(p_active: bool) -> void:
	active = p_active
	timer.paused = not active

func enemy_despawned() -> void:
	enemy_spawned_count -= 1

func _on_timer_timeout() -> void:
	
	if not active or enemy_spawned_count > max_enemies:
		return
		
	var spawners : Array[Node3D] = get_children() as Array[Node3D]
	
	if spawners.is_empty():
		return
	
	var spawn_enemy_chance = rng.randf_range(0,1)
	
	if spawn_enemy_chance <= chance_to_spawn:
		
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.tree_exited.connect(enemy_despawned)
		enemy_spawned_count += 1
		spawn_enemy.emit(enemy_instance)
