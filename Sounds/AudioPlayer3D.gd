extends AudioStreamPlayer3D
class_name SFXAudioPlayer3D

@export_category("Pitch")
@export var randomize_pitch : bool = false
@export_subgroup("Pitch Scale")
@export_range(0.01, 4, 0.01) var min_pitch : float = 1.0
@export_range(0.01, 4, 0.01) var max_pitch : float = 1.5

func play_sound() -> bool:
	
	if playing:
		return false
	
	if randomize_pitch:
		_generate_random_pitch()
	
	play()
	
	return true

func stop_with_fade_out() -> bool:
	
	if not playing:
		return false
		
	var tween = create_tween()
	
	var initial_value_sound = volume_db
	
	tween.tween_property(self, "volume_db", 0, 1.5)
	
	tween.play()
	
	await tween.finished
	
	stop()
	
	volume_db = initial_value_sound
	
	return true

func _generate_random_pitch() -> void:
	pitch_scale = randf_range(min_pitch, max_pitch)
