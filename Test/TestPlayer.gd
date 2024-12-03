extends CharacterBody3D

@export var player_control : PlayerControl

@onready var camera = $Camera

const SPEED = 5.0
const FRICTION = 16.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity = 0.006

func _input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_quit"):
		get_tree().quit(1)

	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var rotation_x = -event.relative.y * mouse_sensitivity
		camera.rotate_x(rotation_x)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta: float) -> void:
	
	# Get input and normalize
	var input_vector = Vector2(
		Input.get_action_strength(player_control.right) - Input.get_action_strength(player_control.left),
		Input.get_action_strength(player_control.down) - Input.get_action_strength(player_control.up)
	).normalized()
	
	# Apply movement
	if input_vector != Vector2.ZERO:
		
		var direction_vector = _translate_input_to_camera(input_vector)
		var movement_speed = direction_vector * SPEED
		velocity = velocity.lerp(movement_speed, FRICTION * delta)
	else:
		# Apply friction only to horizontal axes
		velocity = velocity.lerp(Vector3.ZERO, FRICTION * delta)
		
	# Move and slide with up direction
	move_and_slide()

func _translate_input_to_camera(input: Vector2) -> Vector3:
	
	var camera_pos = camera.get_global_transform().basis
	var direction := Vector3.ZERO
	
	direction += camera_pos.z * input.y
	direction += camera_pos.x * input.x 
	
	direction.y = 0
	direction = direction.normalized()
	
	return direction
