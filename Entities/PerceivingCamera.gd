extends Camera3D
class_name PerceivingCamera3D

@export var max_perceive_distance : float = 26.0

var origin : Node3D

func _ready() -> void:
	origin = get_parent()

func is_looking_at(target: Vector3) -> bool:
		
	if origin.global_position.distance_to(target) > max_perceive_distance:
		return false
		
	if not is_position_in_frustum(target):
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	var from = origin.global_transform.origin
	var to = target
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	return not result or result.collider.global_transform.origin == target
