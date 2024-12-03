extends Node3D

signal spawn_enemy(spawn: EnemySpawn, enemy : Enemy)

@export_range(0.01,1,0.01) var chance_to_spawn : float = 0.25

@onready var timer : Timer = $Timer

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var active : bool = true : set = set_spawner_active

var enemy_spawner_count : int = 0

func _ready() -> void:
	randomize()
	
	var enemies = get_tree().get_nodes_in_group(Enemy.GROUP_NAME)
	
	if enemies is not Array:
		enemies = [enemies]

	for enemy in enemies:
		enemy.running_after_player.connect(enemy_is_running_after)
		
func enemy_is_running_after() -> void:
	active = false
	
func set_spawner_active(p_active: bool) -> void:
	active = p_active
	timer.paused = not active

func _on_timer_timeout() -> void:
	
	if not active:
		return
		
	var player : Player = get_tree().get_current_scene().get_random_player()
	var enemy : Enemy = get_tree().get_current_scene().get_random_enemy()
	
	if enemy.can_change_spawn():
		return
	
	var spawners : Array[Area3D] = player.get_spawners_in_area()
	
	if spawners.is_empty():
		return
	
	var spawn_enemy_chance = rng.randf_range(0,1)
	var spawner_to_spawn = rng.randi_range(0,spawners.size()-1)
	
	if spawn_enemy_chance <= chance_to_spawn:
		spawn_enemy.emit(spawners[spawner_to_spawn] as EnemySpawn, enemy)
