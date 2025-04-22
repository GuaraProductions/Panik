extends CanvasLayer
class_name HUD

@export var player : Player

@onready var hint_page : Label = $Control/HintPage
@onready var page_counter : Label = $Control/PageCounter
@onready var enemy_debug : Label = $Control/EnemyDebug
@onready var black_screen : ColorRect = $BlackScreen

@export var player_controls : PlayerControl

var enemy : CharacterBody3D

func _ready() -> void:
	
	black_screen.visible = false
	enemy = get_tree().current_scene.get_random_enemy()
	
	var action_events = InputMap.action_get_events(player_controls.interact)[0]
	var keycode = action_events.physical_keycode
	var keystring = OS.get_keycode_string(keycode)
	
	var is_on_mobile : bool = true \
	 if OS.has_feature("android") or OS.has_feature("ios") \
	 else false
	
	if is_on_mobile:
		hint_page.text = "Toque na tela para pegar a página"
	else:
		hint_page.text = "Pressione \"%s\" para pegar a página" % keystring

func activate_black_screen() -> void:
	black_screen.visible = true
	black_screen.modulate = Color.WHITE
	
func deactivate_black_screen() -> void:
	black_screen.visible = false

func _process(_delta: float) -> void:
	hint_page.visible = player.looking_at_page

func enemy_changed_state(state: int) -> void:
	pass

func show_page_counter(paper_count: int, num_all_papers: int) -> void:
	page_counter.text = "%d/%d" % [paper_count, num_all_papers]
	page_counter.visible = true
	
	await get_tree().create_timer(5).timeout
	
	page_counter.visible = false
