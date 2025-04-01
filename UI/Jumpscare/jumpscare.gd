extends ColorRect


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AudioStreamPlayer.stop()
	await get_tree().create_timer(2).timeout
	
	get_tree().change_scene_to_file("res://UI/GameOver/GameOver.tscn")
