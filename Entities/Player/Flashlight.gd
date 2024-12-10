extends Node3D

const straight_animation : String = "animation"
const holster_animation : String = "holster"

@onready var light = $model/SpotLight3D
@onready var animation = $AnimationPlayer
@onready var meshes = $model

var is_up : bool = false
var is_holstered : bool = false

func _ready() -> void:
	if light.visible:
		is_holstered = false

func turn_down() -> void:
	
	if animation.is_playing() or is_up or is_holstered:
		return
	
	animation.play(straight_animation)
	
	is_up = true
	
func turn_up() -> void:
	
	if animation.is_playing() or not is_up or is_holstered:
		return
	
	animation.play_backwards(straight_animation)
	
	is_up = false
	
func toggle_light() -> void:
	
	if animation.is_playing():
		return
	
	light.visible = not light.visible
	if is_holstered:
		animation.play_backwards(holster_animation)
		is_holstered = false
	else:
		animation.play(holster_animation)
		is_holstered = true
