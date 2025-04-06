extends ColorRect

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	animation_player.play("Fim")
	
func music_fade_out() -> void:
	var tween = create_tween()
	
	tween.tween_property(
		$AudioStreamPlayer,
		"volume_db",
		-80,
		2
	)
	tween.play()

func _on_voltar_ao_menu_pressed() -> void:
	animation_player.play("BackToMenu")
	music_fade_out()
	
func voltar_ao_menu() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")
