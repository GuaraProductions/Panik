extends Node

@onready var cena_creditos : Control = $CenaCreditos
@onready var main_menu : Control = $MainMenu
@onready var introduction : Control = $GameIntroduction
@onready var options_menu : Control = $MasterOptionsMenu
@onready var sfx : AudioStreamPlayer = $SFX
@onready var music : AudioStreamPlayer = $Music

@export var game_scene : PackedScene

func _ready() -> void:
	cena_creditos.visible = false
	introduction.visible = false
	options_menu.visible = false
	music.play()

func _on_main_menu_go_to_credits() -> void:
	sfx.play()
	main_menu.visible = false
	cena_creditos.fade_in()

func _on_main_menu_go_to_game() -> void:
	sfx.play()
	main_menu.fade_out()
	music_fade_out()
	await main_menu.anim_finished
	introduction.start_intro()
	
func music_fade_out() -> void:
	var tween = create_tween()
	
	tween.tween_property(
		music,
		"volume_db",
		-80,
		2
	)
	tween.play()

func _on_main_menu_go_to_options() -> void:
	sfx.play()
	main_menu.fade_out()
	options_menu.visible = true

func _on_cena_creditos_go_to_menu() -> void:
	sfx.play()
	cena_creditos.fade_out()
	main_menu.fade_in()

func _on_game_introduction_intro_ended() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_master_options_menu_back_to_menu() -> void:
	sfx.play()
	options_menu.visible = false
	main_menu.fade_in()
