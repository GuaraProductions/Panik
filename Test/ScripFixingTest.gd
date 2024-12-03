@tool
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remove_scene_instantiation_from_nodes()

func remove_scene_instantiation_from_nodes() -> void:
	var trees = get_children(true)
	
	for tree in trees:
		
		print("tree.scene_file_path: ",tree.scene_file_path)
		
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
