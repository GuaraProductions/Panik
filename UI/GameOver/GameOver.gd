extends ColorRect

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_voltar_ao_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")
