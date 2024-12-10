extends CanvasLayer
class_name HUD

@export var player : Player

@onready var hint_page : Label = $Control/HintPage
@onready var page_counter : Label = $Control/PageCounter
@onready var enemy_debug : Label = $Control/EnemyDebug
@onready var player_hint : Label = $Control/State
@onready var stalker_patience : ProgressBar = $Control/StalkerPatienceLeft

@export var player_controls : PlayerControl

var enemy : CharacterBody3D

func _ready() -> void:
	
	enemy = get_tree().current_scene.get_random_enemy()
	
	var action_events = InputMap.action_get_events(player_controls.interact)[0]
	var keycode = action_events.physical_keycode
	var keystring = OS.get_keycode_string(keycode)
	hint_page.text = "Pressione \"%s\" para pegar a página" % keystring

func _process(_delta: float) -> void:
	hint_page.visible = player.looking_at_page
	if stalker_patience.visible:
		stalker_patience.value = enemy.get_patience_state()

func enemy_changed_state(state: int) -> void:
	
	if state == Enemy.EnemyState.Wandering:
		player_hint.visible = false
		player_hint.modulate = Color.WHITE
		stalker_patience.visible = false
		return
	
	player_hint.visible = true
	stalker_patience.visible = true
	
	match state:
		Enemy.EnemyState.Intimidated:
			player_hint.modulate = Color.GOLD
			player_hint.text = tr("ESCONDA!")
			
		Enemy.EnemyState.RunningAfter:
			player_hint.modulate = Color.ORANGE_RED
			player_hint.text = tr("CORRA!")
			
		_:
			player_hint.text = ""

func show_page_counter(paper_count: int, num_all_papers: int) -> void:
	page_counter.text = "%d/%d" % [paper_count, num_all_papers]
	page_counter.visible = true
	
	await get_tree().create_timer(5).timeout
	
	page_counter.visible = false
