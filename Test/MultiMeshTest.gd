extends Node3D

@onready var multimesh_instance = $MultiMeshInstance3D

func _ready() -> void:
	multimesh_instance.multimesh.set_instance_transform(0, Transform3D(Basis(), Vector3(0,0,0)))
	multimesh_instance.multimesh.set_instance_transform(1, Transform3D(Basis(), Vector3(0,15,0)))
