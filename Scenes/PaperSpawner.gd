extends Node3D
class_name PaperSpawner

const GROUP_NAME : String = "PaperSpawner"

func _ready() -> void:
	
	if get_child_count() == 1:
		return
	
	var papers = get_children()
	
	var paper_to_stay = papers.pick_random()
	
	for paper in papers:
		if paper != paper_to_stay:
			paper.remove_from_papers()
			paper.queue_free()

func remove_all_papers() -> void:
	#print("removed_papers!")
	for paper in get_children():
		paper.remove_from_papers()
		paper.queue_free()
