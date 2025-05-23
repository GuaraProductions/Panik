class_name Enemy extends CharacterBody3D

signal player_collided()
signal state_changed(state: EnemyState)

const GROUP_NAME : String = "Slender"

enum EnemyState {
	RunningAfter,
	Intimidated,
	WalkingTowards,
	Transforming
}

@export_range(0.05, 1.0, 0.01) var update_pathfinding_wait_time := 0.2
@export_range(1.0,10.0,0.1) var patience_timer : float = 0.0
@export_range(1000,7000,1) var player_detection_raycast_length = 5000

@export var current_state : EnemyState : set = _set_state
@export var running_speed := 15
@export var walking_speed := 4
@export var intimidated_speed := 2

@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var update_pursuit_timer : Timer = $UpdatePursuitTimer
@onready var stalker_patience : Timer = $StalkerPatienceTimer
@onready var camera : PerceivingCamera3D = $Camera3D
@onready var sprite : Sprite3D = $Sprite3D
@onready var death_timer : Timer = $DeathTimer
@onready var animations : AnimationPlayer = $AnimationPlayer
@onready var transformation_audio : AudioStreamPlayer3D = $TransformationAudio
@onready var talks : AudioStreamPlayer3D = $RandomSFXAudioPlayer3D

var enemy_ready := false

var current_target : Vector3 : set = _set_current_target
var target_direction : Vector3

var can_target_player: bool = false

var curr_player : Player

func _ready() -> void:
	player_collided.connect(get_tree().get_current_scene().enemy_got_player)
	enemy_setup.call_deferred()

func _set_state(state: int) -> void:
	print("mudou de estado" , EnemyState.keys()[state])
	current_state = state
	
	match current_state:
		EnemyState.WalkingTowards:
			animations.play("Passive")
		EnemyState.Intimidated:
			animations.play("Intimidated")
		EnemyState.Transforming:
			transformation_audio.play()
			animations.play("Transforming")
			
		EnemyState.RunningAfter:
			#print("vai la meu fio")
			animations.stop()
			animations.play("Pursuing")
			$AudioMonster.play()
	
	state_changed.emit(current_state)

func _set_current_target(target: Vector3) -> void:
	current_target = target
	nav.target_position = target

func enemy_setup() -> void:
	if enemy_ready:
		return
		
	enemy_ready = true
		
	await get_tree().physics_frame
		
	curr_player = get_tree().get_current_scene().get_random_player()
	
	current_state = EnemyState.WalkingTowards
	current_target = curr_player.global_position
		
	enemy_ready = true
	
func _physics_process(_delta: float) -> void:
	
	if not can_target_player:
		return
	
	if target_direction.length() > 0.001:
		var target_rotation_y = atan2(target_direction.x, target_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.1) 

	match current_state:
		EnemyState.RunningAfter:
			move_with_pathfinding(running_speed)
		EnemyState.Intimidated:
			intimitaded()
		EnemyState.WalkingTowards:
			wandering_behavior()

func wandering_behavior() -> void:
	
	if nav.is_navigation_finished():
		current_target = curr_player.global_position
	
	if curr_player and curr_player.is_looking_at_entity(self):
		stalker_patience.start()
		current_state = EnemyState.Intimidated
		return
	
	move_with_pathfinding(walking_speed)
	
func move_with_pathfinding(speed: float = walking_speed) -> void:
	
	if nav.is_navigation_finished() :
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

func intimitaded() -> void:
	
	target_direction = (curr_player.global_position - global_transform.origin).normalized()
	
	if stalker_patience.is_stopped() and curr_player.is_looking_at_entity(self):
			
		current_state = EnemyState.Transforming
		current_target = curr_player.global_position

	elif stalker_patience.is_stopped() and not curr_player.is_looking_at_entity(self):
		
		current_state = EnemyState.WalkingTowards
	
	move_with_pathfinding(intimidated_speed)

func _on_update_pursuit_timer_timeout() -> void:
	
	can_target_player = get_parent().is_point_in_boundary(curr_player.global_position)
	current_target = curr_player.global_position
				

func _on_player_collision(_body: Node3D) -> void:
	player_collided.emit()

func _to_string() -> String:
	return "Enemy: %s\nCurrent_State = %s\nstalker_patience = %.2f\n" % \
			[name, 
			EnemyState.keys()[current_state], 
			stalker_patience.time_left]

func get_patience_state() -> float:
	return stalker_patience.time_left

func _on_stalker_patience_timer_timeout() -> void:
	stalker_patience.stop()
	
func _on_death_timer_timeout() -> void:

	set_physics_process(false)
	talks.play_random()
	animations.play("dissipate")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Transforming":
		current_state = EnemyState.RunningAfter
	if anim_name == "dissipate":
		queue_free()


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	print("antiga: ", old_name)
	print("nova: ", new_name)
