extends AudioStreamPlayer
class_name MusicController

@export var available_music : Array[AudioStream]

var current : int = 0

func play_night_ambience() -> void:
	stream = available_music[0]
	current = 0
	play()
	
func play_horror_ambience() -> void:
	stream = available_music[1]
	current = 1
	play()
	
func play_daytime_ambience() -> void:
	stream = available_music[2]
	current = 2
	play()
	
func play_static_sound() -> void:
	stream = available_music[3]
	current = 3
	play()
