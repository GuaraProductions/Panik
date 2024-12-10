extends CharacterBody3D
class_name Player

enum MovementState {
	WALKING,
	RUNNING,
	IDLE
}

const GROUP_NAME = "Player"

signal page_grabbed(page: Paper)
signal enemy_entered_screen()
signal enemy_exited_screen()

@export var player_control : PlayerControl
@export_range(1000,7000,1) var enemy_detection_raycast_length = 5000

@export_category("Movement")
@export var walking_speed = 4.5
@export var running_speed = 8.5
@export var acceleration = 4.0
@export var friction = 16.0

const RAY_LENGTH = 1000

@onready var camera = $Camera
@onready var flashlight = $Camera/Flashlight
@onready var raycast = $RayCast

@onready var spawner : Area3D = $SpawnerRanger

@onready var footsteps_audio_player : RandomSFXAudioPlayer3D = $RandomAudioPlayer
@onready var flashlight_audio_player : SFXAudioPlayer3D = $FlashlightSounds
@onready var footstep_activator: Area3D = $FootstepActivator

var direction_vector = Vector3.ZERO

var mouse_sensitivity = 0.006
var looking_at_page : bool = false

var enemy_visible : bool = false : set = _set_enemy_visibility

var enemy_in_scene : Node3D

var current_speed : float = walking_speed
var target_speed : float = walking_speed 

var movement_state : MovementState = MovementState.IDLE : set = _set_walking_mode

func _ready() -> void:
	enemy_in_scene = get_tree().current_scene.get_random_enemy()
	add_to_group(GROUP_NAME)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _set_walking_mode(state: int) -> void:
	if state != movement_state and state != MovementState.IDLE:
		footstep_activator.set_deferred("monitorable", true)
		if state == MovementState.RUNNING:
			flashlight.turn_down()
		else: 
			flashlight.turn_up()
	else:
		footstep_activator.set_deferred("monitorable", false)
		
		
	movement_state = state

func _set_enemy_visibility(enemy_is_visible: bool) -> void:
	if enemy_is_visible != enemy_visible:
		if enemy_is_visible:
			enemy_entered_screen.emit()
		else:
			enemy_exited_screen.emit()
			
	enemy_visible = enemy_is_visible

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
		flashlight.toggle_light()
		
func _physics_process(delta: float) -> void:
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta  # Ensure gravity points downward on Y-axis
		
	looking_at_page = raycast.get_collider() != null
	
	enemy_visible = camera.is_looking_at(enemy_in_scene.global_position)

	# Get input and normalize
	var input_vector = Vector2(
		Input.get_action_strength(player_control.right) - Input.get_action_strength(player_control.left),
		Input.get_action_strength(player_control.down) - Input.get_action_strength(player_control.up)
	).normalized()
	
	if looking_at_page and Input.get_action_strength(player_control.interact):
		page_grabbed.emit(raycast.get_collider())
	
	target_speed = running_speed if Input.is_action_pressed(player_control.run) else walking_speed
	
	# Apply movement
	if input_vector != Vector2.ZERO:
		
		footsteps_audio_player.play_random()
		
		if target_speed == running_speed:
			movement_state = MovementState.RUNNING
		else:
			movement_state = MovementState.WALKING
		
		direction_vector = _translate_input_to_camera(input_vector)
		current_speed = lerp(current_speed, target_speed, acceleration * delta)
		var movement_speed = direction_vector * current_speed
		velocity = velocity.lerp(movement_speed, friction * delta)
	else:
		
		movement_state = MovementState.IDLE
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)
		
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
