@tool
extends Node3D

@export var multimesh : MultiMesh

func _ready() -> void:
	if Engine.is_editor_hint():
		remove_scene_instantiation_from_nodes()
	else:
		_setup_multimesh()

func remove_scene_instantiation_from_nodes() -> void:
	
	var trees = get_children(true)
	
	for tree in trees:
		
		if tree.scene_file_path.is_empty():
			return
		
		var static_body = StaticBody3D.new()
		static_body.name = tree.name
		static_body.position = tree.position
		
		var collision = CollisionShape3D.new()
		var original_collision = tree.get_node("CollisionShape3D")
		collision.name = original_collision.name
		collision.shape = original_collision.shape
		collision.position = original_collision.position
		
		var collision_shape = original_collision.shape
		
		collision.shape = collision_shape
		
		remove_child(tree)
		add_child(static_body)
		static_body.owner = get_tree().edited_scene_root
		static_body.add_child(collision)
		collision.owner = get_tree().edited_scene_root

func _remove_mesh_instances() -> void:
	var trees = get_children(true)
	for tree in trees:
		
		if tree is MultiMeshInstance3D:
			continue
		
		var tree_children = tree.get_children(true)
		for child in tree_children:
			if child is MeshInstance3D:
				tree.remove_child(child)
				child.queue_free()

func _setup_multimesh() -> void:
	if find_child("MultiMeshInstance3D"):
		return
		
	# Create a MultiMeshInstance3D node
	var multimesh_instance = MultiMeshInstance3D.new()
	
	multimesh_instance.name = "MultiMeshInstance3D"
	
	var new_multimesh = MultiMesh.new()
	new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	new_multimesh.mesh = multimesh.mesh
	new_multimesh.instance_count = get_child_count()
	
	multimesh_instance.multimesh = new_multimesh
	
	add_child(multimesh_instance)
	
	var trees = get_children(true)
	var counter : int = 0
	for tree in trees:
		
		if tree is MultiMeshInstance3D:
			continue
		
		multimesh_instance.multimesh.set_instance_transform(counter, 
															Transform3D(
																Basis(), 
																tree.position))
		counter += 1
