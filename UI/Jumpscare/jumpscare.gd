extends ColorRect

signal jumpscare_finished()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AudioStreamPlayer.stop()
	await get_tree().create_timer(2).timeout

	jumpscare_finished.emit()
