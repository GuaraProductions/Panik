extends CharacterBody3D
class_name Player

signal page_grabbed(page: Paper)

const SPEED = 5.0
const FRICTION = 16.0
const JUMP_VELOCITY = 4.5

@onready var camera = $Camera
@onready var flashlight = $Light
@onready var flashlight_model = $Camera/Flashlight
@onready var raycast = $RayCast3D

@export var player_control : PlayerControl

var direction_vector = Vector3.ZERO
var velocity_vector = Vector3.ZERO

var mouse_sensitivity = 0.006
var looking_at_page : bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_quit"):
		get_tree().quit(1)
	
	if event is InputEventMouseMotion:
		
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var rotation_x = -event.relative.y * mouse_sensitivity
		camera.rotate_x(rotation_x)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
		
		flashlight.rotate_x(rotation_x)
		flashlight.rotation.x = clamp(flashlight.rotation.x, -1.2, 1.2)
		
	if event.is_action_pressed(player_control.flashlight):
		flashlight.visible = not flashlight.visible
		flashlight_model.visible = not flashlight_model.visible
		

func _physics_process(delta: float) -> void:
	
	var input_vector : Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength(player_control.right) - Input.get_action_strength(player_control.left)
	input_vector.y = Input.get_action_strength(player_control.down) - Input.get_action_strength(player_control.up)
	
	looking_at_page = raycast.get_collider() != null
	
	if looking_at_page and Input.get_action_strength("game_grab_page"):
		print("agarrou objeto")
		page_grabbed.emit(raycast.get_collider())
	
	if input_vector != Vector2.ZERO:
		
		direction_vector = _translate_input_to_camera(input_vector)
		velocity_vector.y = 0
		
		var movement_speed = direction_vector * SPEED
		velocity_vector = velocity_vector.lerp(movement_speed, FRICTION * delta)
		
	else:
		velocity_vector = Vector3.ZERO
	
	set_velocity(velocity_vector)
	move_and_slide()

func _translate_input_to_camera(input: Vector2) -> Vector3:
	
	var camera_pos = camera.get_global_transform().basis
	var direction := Vector3.ZERO
	
	direction += camera_pos.z * input.y
	direction += camera_pos.x * input.x 
	
	direction.y = 0
	direction = direction.normalized()
	
	return direction
