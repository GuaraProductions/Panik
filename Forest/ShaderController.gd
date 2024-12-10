extends CanvasLayer

@onready var chaos_distortion = $ChaosDistortion

func _on_player_enemy_entered_screen() -> void:
	chaos_distortion.visible = true

func _on_player_enemy_exited_screen() -> void:
	chaos_distortion.visible = false
