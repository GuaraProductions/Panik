class_name StaticEnemy extends CharacterBody3D

signal player_collided()

const GROUP_NAME : String = "StaticSlender"

@export var speed := 15
@onready var sprite : Sprite3D = $Sprite3D

var enemy_ready := false

var curr_player : Player

func _ready() -> void:
	player_collided.connect(get_tree().get_current_scene().player_got_bad_ending)

func _on_player_collision(_body: Node3D) -> void:
	player_collided.emit()
