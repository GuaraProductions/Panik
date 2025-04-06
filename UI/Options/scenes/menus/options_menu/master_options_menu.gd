extends MasterOptionsMenu

signal back_to_menu()

func _on_back_pressed() -> void:
	back_to_menu.emit()

func _on_tab_container_tab_clicked(tab: int) -> void:
	$AudioStreamPlayer.play()
