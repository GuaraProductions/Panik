@tool
extends Node3D

const MULTIMESH_NODE_NAME : String = "MultiMeshInstance3D"

@export var multimesh : MultiMesh
@export_category("Debug")
@export var render_trees_in_editor : bool = false : set = _set_render_trees_in_editor
@export var show_debug_prints : bool = false

var multimesh_instance : MultiMeshInstance3D

func _ready() -> void:
	
	multimesh_instance = get_node_or_null(MULTIMESH_NODE_NAME)
	
	if not multimesh_instance:
		return
		
	remove_child(multimesh_instance)
	
	if Engine.is_editor_hint():
		if show_debug_prints: print("remove_scene_instantiation_from_nodes")
		remove_scene_instantiation_from_nodes()
	
	if render_trees_in_editor or not Engine.is_editor_hint():
		if show_debug_prints: print("calling _setup_multimesh")
		_setup_multimesh()
	
func _set_render_trees_in_editor(value: bool) -> void:
	print("[setter]: render_trees_in_editor: ", value)

	render_trees_in_editor = value
	
	if not is_node_ready():
		return
	
	if render_trees_in_editor:
		if show_debug_prints: print("multimesh_instance.visible = true")
		_setup_multimesh()
	elif not render_trees_in_editor:
		if show_debug_prints: print("multimesh_instance.visible = false")
		_remove_multimesh()

func _remove_multimesh() -> void:
	if multimesh_instance:
		remove_child(multimesh_instance)

func create_multimesh(count: int) -> MultiMesh:
	
	var new_multimesh : MultiMesh = MultiMesh.new()
	
	new_multimesh.transform_format = multimesh.transform_format
	new_multimesh.instance_count = count
	new_multimesh.mesh = multimesh.mesh
	
	return new_multimesh

func remove_scene_instantiation_from_nodes() -> void:
	
	var trees = get_children(true)
	
	for tree in trees:
		
		if tree.scene_file_path.is_empty():
			if show_debug_prints: print("tree.scene_file_path.is_empty()")
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
		
	if show_debug_prints: print("setting up multimesh...")
		
	if not multimesh_instance:
		multimesh_instance = get_node_or_null(MULTIMESH_NODE_NAME)
		
	if not multimesh_instance:
	
		if show_debug_prints: print("# Create a MultiMeshInstance3D node")
		# Create a MultiMeshInstance3D node
		multimesh_instance = MultiMeshInstance3D.new()
		
		multimesh_instance.name = MULTIMESH_NODE_NAME
		
		add_child(multimesh_instance)
		if Engine.is_editor_hint():
			multimesh_instance.owner = get_tree().edited_scene_root
			
		multimesh_instance.multimesh = create_multimesh(get_child_count() - 1)
	
	var trees = get_children(true)
	var counter : int = 0
	
	if not multimesh_instance.multimesh:
		return
	
	for tree in trees:
		
		if tree is MultiMeshInstance3D:
			continue
		
		multimesh_instance.multimesh.set_instance_transform(counter, 
															Transform3D(
																Basis(), 
																tree.position))
		counter += 1
		
