extends Node3D

@export var hud : HUD
@export var game_over_scene : PackedScene
@export var you_win_scene : PackedScene
@onready var music_player: MusicController = $Music
@onready var shaders_screen : CanvasLayer = $Shaders

@onready var enemy_spawner : EnemySpawner = $EnemySpawnHandler
@onready var final_cutcene_spawn : Marker3D = $FinalCutcene

@export var night_environment = Environment
@export var day_environment = Environment
@onready var world_environment = $WorldEnvironment
@onready var animation_player = $FinalCutcene/AnimationPlayer
@onready var player : Player = $Player

var page_counter : int = 0
var num_pages : int = 0

func _ready() -> void:
	#music_player.play_night_ambience()
	#player_got_all_pages()
	
	var paper_spawners = get_tree().get_nodes_in_group(PaperSpawner.GROUP_NAME)
	
	var paper_to_remove_1 = paper_spawners.pick_random()
	
	paper_to_remove_1.remove_all_papers()
	
	num_pages = get_tree().get_node_count_in_group(Paper.GROUP_NAME)
	
func change_to_day_time() -> void:
	world_environment.environment = day_environment
	
func change_to_night_time() -> void:
	world_environment.environment = night_environment
	
func player_grabbed_page(page: Paper) -> void:
	page_counter += 1

	if page_counter == 1:
		music_player.play_horror_ambience()
		enemy_spawner.active = true
		
	if page_counter == 2:
		enemy_spawner.decoy_active = true
		enemy_spawner.max_decoys = 1
	
	if page_counter == 5:
		enemy_spawner.max_enemies = 2
		
	if page_counter == 6:
		enemy_spawner.max_enemies = 3
		enemy_spawner.max_decoys = 2
	
	if page:
		page.grab()
		hud.show_page_counter(page_counter, num_pages)

	if page_counter >= num_pages:
		player_got_all_pages()

func _jumpscare_trigger() -> void:
	$AnimationPlayer.play("Jumpscare")

func _fake_jumpscare_trigger() -> void:
	$AnimationPlayer.play("FakeJumpscare")

func _on_enemy_spawn_handler_spawn_enemy(enemy: Node3D, spawn: Vector3) -> void:
	
	if enemy is Jester:
		enemy.trigger_jumpscare.connect(_jumpscare_trigger, CONNECT_ONE_SHOT)
		enemy.trigger_fake.connect(_fake_jumpscare_trigger, CONNECT_ONE_SHOT)
	
	add_child(enemy)
	
	enemy.set_deferred("global_position", spawn)
	
func get_random_player() -> Player:
	var players = get_tree().get_nodes_in_group(Player.GROUP_NAME)
	
	if players.is_empty():
		return null
	
	return players.pick_random()
	
func get_random_enemy() -> Enemy:
	var enemies = get_tree().get_nodes_in_group(Enemy.GROUP_NAME)
	
	if enemies.is_empty():
		return null
	
	return enemies.pick_random()

func player_got_all_pages() -> void:
	
	enemy_spawner.deactivate()
	music_player.stop()
	await get_tree().create_timer(5).timeout
	player.set_process(false)
	hud.activate_black_screen()
	await get_tree().create_timer(4).timeout
	music_player.play()
	animation_player.play("FinalCutcene")
	music_player.play_static_sound()
	hud.deactivate_black_screen()
	player.set_process(true)
	
func get_good_ending() -> void:
	music_player.stop()
	player.set_process(false)
	hud.activate_black_screen()
	player.disable_flashlight()
	await get_tree().create_timer(5).timeout
	change_to_day_time()
	hud.deactivate_black_screen()
	music_player.play_daytime_ambience()
	player.set_process(true)
	
func enemy_got_player() -> void:
	get_tree().change_scene_to_packed.call_deferred(game_over_scene)

func _on_you_win_trigger_body_entered(_body: Node3D) -> void:
	music_player.stop()
	hud.activate_black_screen()
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed.call_deferred(you_win_scene)
