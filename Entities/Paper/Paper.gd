extends Area3D
class_name Paper

const GROUP_NAME := "Paper"

@export var active: bool = true
@onready var audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var meshes : Node3D = $Meshes

func _ready() -> void:
	add_to_group(GROUP_NAME)

func grab() -> void:

	if not active:
		return
		
	active = false
	set_collision_layer_value(2, false)
	
	meshes.visible = false
	audio_stream_player.play()
	
	await audio_stream_player.finished
	queue_free()

func remove_from_papers() -> void:
	remove_from_group(GROUP_NAME)
