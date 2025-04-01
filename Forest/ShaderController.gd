extends CanvasLayer

@onready var crt : ColorRect = $CRT
@onready var jumpscare : Control = $Jumpscare

func _ready() -> void:
	jumpscare.visible = false
