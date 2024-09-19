extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var directional_light : DirectionalLight3D = $DirectionalLight3D

enum LightMode {
	Daylight,
	Night_time
}

@export var light_mode : LightMode = LightMode.Daylight

@export var pages : Array[Paper] 
var page_counter : int = 0
var num_pages : int = 0

@export var hud : HUD
@export var player : Player

func _ready() -> void:
	num_pages = pages.size()
	if light_mode == LightMode.Night_time:
		directional_light.light_energy = 0.05
		
	elif light_mode == LightMode.Daylight:
		directional_light.light_energy = 1.36
	
func player_grabbed_page(page: Paper) -> void:
	page_counter += 1
	pages.erase(page)
	page.queue_free()
	hud.show_page_counter(page_counter, num_pages)
