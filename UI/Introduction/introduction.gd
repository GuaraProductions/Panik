extends ColorRect

signal intro_ended()

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var music_player : AudioStreamPlayer = $AudioStreamPlayer

var intro_happened = false
var intro_started = false
var music_faded_out = false

func start_intro() -> void:
	animation_player.play("Intro")
	
	await get_tree().create_timer(1).timeout
	
	intro_started = true

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventJoypadButton) and not intro_happened and intro_started:
		animation_player.seek(25, true)
		intro_happened = true
		fade_out_music()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	intro_ended.emit()

func fade_out_music() -> void:
	
	if music_faded_out:
		return
	
	var sound_tween = create_tween()
	
	sound_tween.tween_property(
		music_player,
		"volume_db",
		-80,
		15
	)
	
	sound_tween.play()
	music_faded_out = true
	

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	await get_tree().create_timer(25).timeout
	intro_happened = true
	fade_out_music()
