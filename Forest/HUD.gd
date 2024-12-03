extends CanvasLayer
class_name HUD

@export var player : Player

@onready var hint_page : Label = $Control/HintPage
@onready var page_counter : Label = $Control/PageCounter
@onready var enemy_debug : Label = $Control/EnemyDebug

@export var player_controls : PlayerControl

var enemy : CharacterBody3D = null

func _ready() -> void:
	
	enemy = get_tree().get_current_scene().get_random_enemy()
	print("enemy: ", enemy)
	
	var action_events = InputMap.action_get_events(player_controls.interact)[0]
	var keycode = action_events.physical_keycode
	var keystring = OS.get_keycode_string(keycode)
	hint_page.text = "Pressione \"%s\" para pegar a página" % keystring

func _process(_delta: float) -> void:
	if enemy:
		enemy_debug.set_text(enemy._to_string())
		
	hint_page.visible = player.looking_at_page

func show_page_counter(paper_count: int, num_all_papers: int) -> void:
	page_counter.text = "%d/%d" % [paper_count, num_all_papers]
	page_counter.visible = true
	
	await get_tree().create_timer(5).timeout
	
	page_counter.visible = false
