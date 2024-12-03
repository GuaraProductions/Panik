extends CharacterBody3D
class_name Player

const GROUP_NAME = "Player"

signal page_grabbed(page: Paper)

const SPEED = 5.0
const FRICTION = 16.0
const JUMP_VELOCITY = 4.5

const RAY_LENGTH = 1000

@onready var camera = $Camera
@onready var flashlight = $Camera/Light
@onready var flashlight_model = $Camera/Flashlight
@onready var raycast = $RayCast

@onready var spawner : Area3D = $SpawnerRanger

@onready var footsteps_audio_player : RandomSFXAudioPlayer3D = $RandomAudioPlayer
@onready var flashlight_audio_player : SFXAudioPlayer3D = $FlashlightSounds

@export var player_control : PlayerControl

@export_range(1000,7000,1) var enemy_detection_raycast_length = 5000

var direction_vector = Vector3.ZERO

var mouse_sensitivity = 0.006
var looking_at_page : bool = false

var enemy_visible : bool = false

func _ready() -> void:
	add_to_group(GROUP_NAME)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_quit"):
		get_tree().quit(1)

	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var rotation_x = -event.relative.y * mouse_sensitivity
		camera.rotate_x(rotation_x)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
		
	if event.is_action_pressed(player_control.flashlight):
		flashlight_audio_player.play()
		flashlight.visible = not flashlight.visible
		flashlight_model.visible = not flashlight_model.visible

func _physics_process(delta: float) -> void:
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta  # Ensure gravity points downward on Y-axis

	# Get input and normalize
	var input_vector = Vector2(
		Input.get_action_strength(player_control.right) - Input.get_action_strength(player_control.left),
		Input.get_action_strength(player_control.down) - Input.get_action_strength(player_control.up)
	).normalized()

	looking_at_page = raycast.get_collider() != null
	
	if looking_at_page and Input.get_action_strength(player_control.interact):
		page_grabbed.emit(raycast.get_collider())
		
	# Apply movement
	if input_vector != Vector2.ZERO:
		
		footsteps_audio_player.play_random()
		
		direction_vector = _translate_input_to_camera(input_vector)
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

func get_direction() -> Vector3:
	return -camera.global_transform.basis.z.normalized()
	
func get_camera_origin() -> Vector3:
	return camera.global_transform.origin

func get_spawners_in_area() -> Array:
	return spawner.get_overlapping_areas()
