extends ColorRect

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	animation_player.play("Fim")
	
	#animation_player.seek(30,true)

func _on_voltar_ao_menu_pressed() -> void:
	animation_player.play("BackToMenu")
	
func voltar_ao_menu() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")
