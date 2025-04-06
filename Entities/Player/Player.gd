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
@export var exausted_speed = 3.5
@export var acceleration = 4.0
@export var friction = 16.0

@export_category("Stamina")
@export var max_stamina := 10
@export var stamina_loss_speed = 5
@export var stamina_recover_speed = 20

const RAY_LENGTH = 1000

@onready var camera = $Camera
@onready var flashlight = $Camera/Flashlight
@onready var raycast = $Camera/RayCast

@onready var normal_footsteps : RandomSFXAudioPlayer3D = $NormalFootsteps
@onready var fast_footsteps : RandomSFXAudioPlayer3D = $FastFootsteps
@onready var flashlight_audio_player : SFXAudioPlayer3D = $FlashlightSounds
@onready var breathing_sound : SFXAudioPlayer3D = $BreathingSound
@onready var exausted_timer : Timer = $ExaustedTimer

var direction_vector = Vector3.ZERO

var mouse_sensitivity = 0.006
var looking_at_page : bool = false

var enemy_visible : bool = false : set = _set_enemy_visibility

var enemy_in_scene : Node3D

var current_speed : float = walking_speed
var target_speed : float = walking_speed 

var movement_state : MovementState = MovementState.IDLE : set = _set_walking_mode

var _is_stamina_recovering : bool = false
var current_stamina : float = max_stamina

var flashlight_disabled : bool = false


func _ready() -> void:
	add_to_group(GROUP_NAME)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func disable_flashlight() -> void:
	flashlight_disabled = true
	flashlight.visible = false

func _set_walking_mode(state: int) -> void:
	
	if state != movement_state and state != MovementState.IDLE:
		if state == MovementState.RUNNING:
			flashlight.turn_down()
		else: 
			flashlight.turn_up()
		
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
		
	if event.is_action_pressed(player_control.flashlight) and not flashlight_disabled:
		flashlight_audio_player.play()
		flashlight.toggle_light(movement_state == MovementState.RUNNING)
		
func _physics_process(delta: float) -> void:
	
	looking_at_page = raycast.get_collider() != null
	
	if looking_at_page and Input.get_action_strength(player_control.interact):
		page_grabbed.emit(raycast.get_collider())
	
	var right_stick_vector = Input.get_vector("joystick_left","joystick_right","joystick_up","joystick_down")
	#enemy_visible = camera.is_looking_at(enemy_in_scene.global_position)
	
	if right_stick_vector:
		
		var event := InputEventMouseMotion.new()
		event.relative = right_stick_vector * 8
		Input.parse_input_event(event)  # Simulate mouse movement
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta  # Ensure gravity points downward on Y-axis

	# Get input and normalize
	var input_vector = Vector2(
		Input.get_action_strength(player_control.right) - Input.get_action_strength(player_control.left),
		Input.get_action_strength(player_control.down) - Input.get_action_strength(player_control.up)
	).normalized()
	
	if current_stamina < 1:
		breathing_sound.play_sound()
		exausted_timer.start()
	
	# Apply movement
	if input_vector != Vector2.ZERO:

		if Input.is_action_pressed(player_control.run) and current_stamina > 1 and exausted_timer.is_stopped():
			target_speed = running_speed
			movement_state = MovementState.RUNNING
			fast_footsteps.play_random()

			_is_stamina_recovering = false
			current_stamina = clampf(current_stamina - stamina_loss_speed * delta, 0 , max_stamina)
			
		else:
			if not _is_stamina_recovering:
				_is_stamina_recovering = true

			target_speed = walking_speed if exausted_timer.is_stopped() else exausted_speed
			movement_state = MovementState.WALKING
			normal_footsteps.play_random()
		
		direction_vector = _translate_input_to_camera(input_vector)
		current_speed = lerp(current_speed, target_speed, acceleration * delta)
		var movement_speed = direction_vector * current_speed
		velocity = velocity.lerp(movement_speed, friction * delta)

	else:
		
		movement_state = MovementState.IDLE
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)
		
	if _is_stamina_recovering and current_stamina < max_stamina:
		current_stamina = clampf(current_stamina + stamina_loss_speed * delta, 0 , max_stamina)
		
	move_and_slide()

func _translate_input_to_camera(input: Vector2) -> Vector3:
	
	var camera_pos = camera.get_global_transform().basis
	var direction := Vector3.ZERO
	
	direction += camera_pos.z * input.y
	direction += camera_pos.x * input.x 
	
	direction.y = 0
	direction = direction.normalized()
	
	return direction

func is_looking_at_entity(node: Node3D) -> bool:
	return camera.is_looking_at(node.global_position)

func get_direction() -> Vector3:
	return -camera.global_transform.basis.z.normalized()
	
func get_camera_origin() -> Vector3:
	return camera.global_transform.origin

func get_spawners_in_area() -> Array:
	return []

func _on_exausted_timer_timeout() -> void:
	breathing_sound.stop_with_fade_out()
	exausted_timer.stop()
