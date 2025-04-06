class_name Jester extends CharacterBody3D

signal player_collided()
signal trigger_jumpscare()
signal trigger_fake()

const GROUP_NAME : String = "Jester"

@export_range(0.05, 1.0, 0.01) var update_pathfinding_wait_time := 0.2
@export_range(1.0,10.0,0.1) var patience_timer : float = 0.0
@export_range(1000,7000,1) var player_detection_raycast_length = 5000

@export var running_speed := 15

@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var update_pursuit_timer : Timer = $UpdatePursuitTimer
@onready var sprite : Sprite3D = $Sprite3D
@onready var death_timer : Timer = $DeathTimer
@onready var animations : AnimationPlayer = $AnimationPlayer

var enemy_ready := false

var current_target : Vector3 : set = _set_current_target
var target_direction : Vector3

var can_target_player: bool = false

var curr_player : Player

func _ready() -> void:
	player_collided.connect(collided_with_player)
	enemy_setup.call_deferred()

func collided_with_player() -> void:
	if not curr_player.is_looking_at_entity(self):
		trigger_jumpscare.emit()
	else:
		trigger_fake.emit()
	queue_free()

func _set_current_target(target: Vector3) -> void:
	current_target = target
	nav.target_position = target

func enemy_setup() -> void:
	if enemy_ready:
		return
		
	enemy_ready = true
		
	await get_tree().physics_frame
		
	curr_player = get_tree().get_current_scene().get_random_player()
	
	current_target = curr_player.global_position
		
	enemy_ready = true
	
func _physics_process(_delta: float) -> void:
	
	if not can_target_player:
		return
	
	$SFXAudioPlayer3D.play()
	if target_direction.length() > 0.001:
		var target_rotation_y = atan2(target_direction.x, target_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.1) 

	move_with_pathfinding(running_speed)

func move_with_pathfinding(speed: float = running_speed) -> void:
	
	if nav.is_navigation_finished():
		return
	
	var cur_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = nav.get_next_path_position()

	# Calculate the velocity towards the next position
	var new_velocity: Vector3 = next_path_position - cur_agent_position

	if new_velocity.length() > 0.01: # Avoid unnecessary rotation when close to target
		# Normalize and apply speed
		new_velocity = new_velocity.normalized() * speed

		# Rotate the character towards the direction of movement (only in the Y-axis)
		target_direction = new_velocity.normalized()
		
	# Apply velocity
	velocity = new_velocity
	move_and_slide()

func _on_update_pursuit_timer_timeout() -> void:
	
	can_target_player = get_parent().is_point_in_boundary(curr_player.global_position)
	current_target = curr_player.global_position
				
func _on_player_collision(_body: Node3D) -> void:
	player_collided.emit()
	
func _on_death_timer_timeout() -> void:
	queue_free()
