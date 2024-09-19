extends Resource
class_name PlayerControl

@export var left : String = ""
@export var right : String = ""
@export var up : String = ""
@export var down : String = ""
@export var flashlight : String = ""

func _init(p_left : String = left, 
		   p_right : String = right, 
		   p_up : String = up, 
		   p_down: String = down,
		   p_flashlight: String = flashlight) -> void:
	left = p_left
	right = p_right
	down = p_down
	up = p_up
	flashlight = p_flashlight
