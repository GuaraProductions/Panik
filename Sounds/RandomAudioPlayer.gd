extends SFXAudioPlayer3D
class_name RandomSFXAudioPlayer3D

@export var audio_streams : Array[AudioStream]

func play_random() -> bool:
	
	if playing:
		return false
	
	stream = audio_streams.pick_random()
	_generate_random_pitch()
	
	play()
	
	return true
