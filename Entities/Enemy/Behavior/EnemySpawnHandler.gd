extends Node3D
class_name EnemySpawner

signal spawn_enemy(enemy : Node3D, spawn_position: Vector3)

const MINIMUM_DISTANCE : float = 30
const DISTANCE_TO_FILTER : float = 25

@export var active : bool = true : set = set_spawner_active
@export var decoy_active : bool = true : set = set_decoy_spawner_active
@export var player : Player

@export_category("Scenes")
@export var enemy_scene : PackedScene
@export var decoy_scene : PackedScene

@export_category("Enemy configuration")
@export_range(1,5,1) var max_enemies : int = 1
@export_range(0.01,1,0.01) var enemy_chance_to_spawn : float = 0.25
@export_range(MINIMUM_DISTANCE,100,0.1) var enemy_spawn_distance : float = 80

@export_category("Decoy configuration")
@export_range(1,5,1) var max_decoys : int = 1
@export_range(0.01,1,0.01) var decoy_chance_to_spawn : float = 0.25
@export_range(MINIMUM_DISTANCE,100,0.1) var decoy_spawn_distance : float = 80

@onready var timer : Timer = $Timer
@onready var decoy_timer : Timer = $DecoyTimer

var enemy_spawned_count : int = 0
var decoy_spawned_count : int = 0

var _spawners : Array[Node]

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _last_player_position : Vector3 = Vector3.ZERO

var enemies : Array[Node3D] = []

func _ready() -> void:
	randomize()
	if player:
		_last_player_position = player.global_position
		
	update_spawners()

func deactivate() -> void:
	decoy_active = false
	active = false
	destroy_all_enemies()

func destroy_all_enemies() -> void:
	for enemy in enemies:
		if enemy:
			enemy.queue_free()
			
	enemies.clear()

func update_spawners(new_distance: float = MINIMUM_DISTANCE) -> void:
	
	enemy_chance_to_spawn = new_distance
	_filter_spawners()

func _filter_spawners() -> void:
	var new_spawners = get_children()
	if player:
		_spawners = new_spawners.filter(_spawners_filter)
		_last_player_position = player.global_position

func enemy_is_running_after() -> void:
	active = false
	
func set_spawner_active(p_active: bool) -> void:
	active = p_active
	$Timer.paused = not active
	
func set_decoy_spawner_active(p_active: bool) -> void:
	decoy_active = p_active
	$DecoyTimer.paused = not decoy_active

func enemy_despawned(enemy: Enemy) -> void:
	enemy_spawned_count -= 1
	if enemy:
		enemies.erase(enemy)
	
func decoy_despawned(decoy: Jester) -> void:
	decoy_spawned_count -= 1
	if decoy:
		enemies.erase(decoy)

func _spawners_filter(a: Node) -> bool: 
	return a is Marker3D \
		and a.global_position.distance_to(player.global_position) >= enemy_chance_to_spawn

func _cant_spawn_enemy() -> bool:
	return not active \
	or enemy_spawned_count >= max_enemies \
	or _spawners.is_empty() \
	or not player \
	or not enemy_scene.can_instantiate()
	
func _cant_spawn_decoy() -> bool:
	return not decoy_active \
	or decoy_spawned_count >= max_decoys \
	or _spawners.is_empty() \
	or not player \
	or not decoy_scene.can_instantiate()

func _on_timer_timeout() -> void:
	
	if _cant_spawn_enemy():
		return
	
	var spawn_enemy_chance = rng.randf_range(0,1)
		
	var enemy_instance : Enemy = enemy_scene.instantiate()
	enemy_instance.tree_exited.connect(enemy_despawned.bind(enemy_instance))
	enemies.append(enemy_instance)
	enemy_spawned_count += 1
	spawn_enemy.emit(enemy_instance, _spawners.pick_random().global_position)

func _on_filter_spawner_timer_timeout() -> void:
	if _last_player_position.distance_to(player.global_position) > DISTANCE_TO_FILTER:
		_filter_spawners()

func _on_decoy_timer_timeout() -> void:
	
	if _cant_spawn_decoy():
		return
	
	var spawn_enemy_chance = rng.randf_range(0,1)
		
	var decoy_instance : Jester = decoy_scene.instantiate()
	decoy_instance.tree_exited.connect(decoy_despawned.bind(decoy_instance))
	enemies.append(decoy_instance)
	decoy_spawned_count += 1
	spawn_enemy.emit(decoy_instance, _spawners.pick_random().global_position)
