extends ColorRect

@export var cena_do_jogo : PackedScene

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(cena_do_jogo)
	
func _on_exit_pressed() -> void:
	get_tree().quit()
