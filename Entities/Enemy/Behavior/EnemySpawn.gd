extends Area3D
class_name EnemySpawn

@export var spawns: Array[Marker3D]

const GROUP_NAME := "EnemySpawn"

func _ready() -> void:
	add_to_group(GROUP_NAME)

func find_most_distant_from_player(player_position: Vector3) -> Vector3:
	
	if spawns.is_empty():
		return player_position
	
	var most_distant : Vector3 = spawns[0].global_position
	
	for spawn in spawns:
		if player_position.distance_to(spawn.global_position) > player_position.distance_to(most_distant):
			most_distant = spawn.global_position
			
	return most_distant
