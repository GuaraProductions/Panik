class_name Enemy extends CharacterBody3D

signal running_after_player()
signal player_collided()

const GROUP_NAME : String = "Slender"

enum EnemyState {
	RunningAfter,
	Stalking,
	Intimidated,
	Wandering
}

@export_range(0.05, 1.0, 0.01) var update_pathfinding_wait_time := 0.2
@export_range(1.0,10.0,0.1) var patience_timer : float = 0.0
@export_range(1000,7000,1) var player_detection_raycast_length = 5000

@export var current_state : EnemyState = EnemyState.Wandering
@export var running_speed := 15
@export var walking_speed := 4.5

@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var update_pursuit_timer : Timer = $UpdatePursuitTimer
@onready var rage_timer : Timer = $RageTimer
@onready var stalker_patience : Timer = $StalkerPatienceTimer
@onready var camera : Camera3D = $Camera3D

var is_player_looking_into_enemy : bool

var enemy_ready := false

var has_target : bool = false
var current_target : Vector3

var curr_player : Player

func _ready() -> void:
	player_collided.connect(get_tree().get_current_scene().enemy_got_player)
	enemy_setup.call_deferred()
	
func enemy_setup() -> void:
	if enemy_ready:
		return
		
	curr_player = get_tree().get_current_scene().get_random_player()
		
	await get_tree().physics_frame
		
	enemy_ready = true
	
func _physics_process(_delta: float) -> void:


	match current_state:
		EnemyState.RunningAfter:
			run_after_player()
		EnemyState.Stalking:
			stalk_player()
		EnemyState.Intimidated:
			intimitaded()
		EnemyState.Wandering:
			wandering_behavior()
			

func get_new_target_to_wander() -> Vector3:
	
	var papers : Array[Node] = get_tree().get_nodes_in_group(Paper.GROUP_NAME)
	
	return papers.pick_random().global_position

func wandering_behavior() -> void:
	
	if not has_target:
		has_target = true
		current_target = get_new_target_to_wander()
	
	if nav.is_navigation_finished():
		current_target = get_new_target_to_wander()
	
	#print(is_looking_at_player())
	
	#move_with_pathfinding()
	
func run_after_player() -> void:
	if nav.is_navigation_finished():
		return
		
	move_with_pathfinding()

func move_with_pathfinding() -> void:
	
	var cur_agent_position : Vector3 = global_position
	var next_path_position : Vector3 = nav.get_next_path_position()
	
	var new_velocity : Vector3 = next_path_position - cur_agent_position
	new_velocity = new_velocity.normalized() * walking_speed
	
	velocity = new_velocity
	move_and_slide()

func intimitaded() -> void:
		
	if not is_player_looking_into_enemy:
		if not rage_timer.is_stopped():
			rage_timer.stop()
			current_state = EnemyState.Stalking
			stalker_patience.start(5)

func stalk_player() -> void:
		
	if not curr_player:
		return

	if is_player_looking_into_enemy:
		if rage_timer.is_stopped():
			rage_timer.start(patience_timer)
			stalker_patience.stop()
			current_state = EnemyState.Intimidated

func _on_rage_timer_timeout() -> void:
	running_after_player.emit()
	current_state = EnemyState.RunningAfter

func _on_update_pursuit_timer_timeout() -> void:
	if nav.is_navigation_finished():
		nav.target_position = current_target

func _on_player_collision(_body: Node3D) -> void:
	player_collided.emit()

func can_change_spawn() -> bool:
	return current_state != EnemyState.Wandering

func _on_stalker_patience_timer_timeout() -> void:
	current_state = EnemyState.Wandering

func _to_string() -> String:
	return "Enemy: %s\nCurrent_State = %s\nrage_timer = %.2f\nstalker_patience = %.2f\n" % \
			[name, 
			EnemyState.keys()[current_state], 
			rage_timer.time_left, 
			stalker_patience.time_left]

func is_looking_at_enemy() -> bool:
	
	if not curr_player:
		return false
		
	if global_position.distance_to(curr_player.global_position) > 36.0:
		return false
		
	if not camera.is_position_in_frustum(curr_player.global_position):
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	var from = global_transform.origin
	var to = curr_player.global_position
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	return not result or result.collider.global_transform.origin == curr_player.global_position
