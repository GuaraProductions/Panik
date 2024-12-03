extends Node3D

@onready var world_environment = $WorldEnvironment

var page_counter : int = 0
var num_pages : int = 0

@export var hud : HUD
@export var game_over_scene : PackedScene
@export var you_win_scene : PackedScene

func _ready() -> void:
	num_pages = get_tree().get_node_count_in_group(Paper.GROUP_NAME)
	
func player_grabbed_page(page: Paper) -> void:
	page_counter += 1
	page.grab()
	hud.show_page_counter(page_counter, num_pages)

	if page_counter >= num_pages:
		player_got_all_pages()

func _on_enemy_spawn_handler_spawn_enemy(enemy_spawner: EnemySpawn, enemy: Enemy) -> void:
	
	var player : Player = get_random_player()

	var enemy_spawn_position = enemy_spawner.find_most_distant_from_player(player.global_position)
	
	enemy.global_position = enemy_spawn_position
	
func get_random_player() -> Player:
	var players = get_tree().get_nodes_in_group(Player.GROUP_NAME)
		
	return players[0]
	
func get_random_enemy() -> Enemy:
	var enemies = get_tree().get_nodes_in_group(Enemy.GROUP_NAME)
	
	return enemies[0]

func player_got_all_pages() -> void:
	
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(you_win_scene)

func enemy_got_player() -> void:
	get_tree().change_scene_to_packed.call_deferred(game_over_scene)
