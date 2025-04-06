extends ColorRect

signal go_to_menu()

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _on_voltar_ao_menu_pressed() -> void:
	go_to_menu.emit()

func fade_in() -> void:
	animation_player.play("FadeIn")

func fade_out() -> void:
	animation_player.play("FadeOut")
