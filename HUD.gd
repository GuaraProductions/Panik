extends CanvasLayer
class_name HUD

@export var player : Player

@onready var hint_page : Label = $Control/HintPage
@onready var page_counter : Label = $Control/PageCounter
@export var player_controls : PlayerControl

func _ready() -> void:
	hint_page.text = "Pressione \"%s\" para pegar a página" % player_controls.flashlight

func _process(delta: float) -> void:
	hint_page.visible = player.looking_at_page

func show_page_counter(paper_count: int, num_all_papers: int) -> void:
	page_counter.text = "%d/%d" % [paper_count, num_all_papers]
	page_counter.visible = true
	
	await get_tree().create_timer(5).timeout
	
	page_counter.visible = false
