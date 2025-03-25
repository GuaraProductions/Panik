extends CanvasLayer

@onready var crt : ColorRect = $CRT
@onready var jumpscare : Control = $Jumpscare

func _ready() -> void:
	jumpscare.visible = false

func show_jumpscare() -> void:
	
	var random_time : float = randf_range(1.2,1.5)
	
	jumpscare.visible = true
	await get_tree().create_timer(random_time).timeout
	jumpscare.visible = false
