extends Control

signal anim_finished(anim_name : String)

signal go_to_game()
signal go_to_options()
signal go_to_credits()

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _on_start_pressed() -> void:
	go_to_game.emit()
	
func _on_options_pressed() -> void:
	go_to_options.emit()
	
func _on_credits_pressed() -> void:
	go_to_credits.emit()
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func fade_in() -> void:
	animation_player.play("FadeIn")
	
func fade_out() -> void:
	animation_player.play("FadeOut")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_finished.emit(anim_name)
