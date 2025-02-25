extends Node3D
class_name PaperSpawner

const GROUP_NAME : String = "PaperSpawner"

func _ready() -> void:
	
	if get_child_count() == 1:
		return
	
	var paper_to_stay : int = randi_range(0, get_child_count()-1)
	
	var papers_to_remove : Array[Paper] = []
	
	var paper_index : int = 0
	
	for paper in get_children():
		
		if paper_index == paper_to_stay:
			paper.add_to_group(Paper.GROUP_NAME)
		else:
			papers_to_remove.append(paper)
		
		paper_index += 1
		
	for paper in papers_to_remove:
		paper.queue_free()


func remove_all_papers() -> void:
	print("removed_papers!")
	for paper in get_children():
		paper.queue_free()
