extends Control

@onready var joystick_left : Control = $"Virtual Joystick"
@onready var joystick_right : Control = $"Virtual Joystick2"
@onready var touch_run_button : TouchScreenButton = $TouchRunButton

@export var player_controls : PlayerControl

var previous_directions: Array[String] = []

func _ready() -> void:
	
	var is_on_mobile : bool = true \
	 if OS.has_feature("android") or OS.has_feature("ios") \
	 else false
	
	joystick_left.visible = is_on_mobile
	joystick_right.visible = is_on_mobile
	set_physics_process(is_on_mobile)
	set_process_input(is_on_mobile)
	touch_run_button.visible = is_on_mobile

func _physics_process(delta: float) -> void:
	
	if joystick_right and joystick_right.is_pressed:
		var event := InputEventMouseMotion.new()
		event.relative = joystick_right.output.angle() * 8
		Input.parse_input_event(event)  # Simulate mouse movement
		
	if joystick_left and joystick_left.is_pressed:
		var angle = joystick_left.output.angle()
		var directions = get_directions_from_angle(angle)

		for key_str in directions:

			var event := InputEventAction.new()
			event.action = key_str
			event.pressed = true
			event.strength = 1.0
			Input.parse_input_event(event)

		previous_directions = directions
	else:
		# Joystick released
		for key_str in previous_directions:

			var event := InputEventAction.new()
			event.action = key_str
			event.pressed = false
			event.strength = 0.0
			Input.parse_input_event(event)

		previous_directions = []

func get_directions_from_angle(angle: float) -> Array[String]:
	angle = fmod(angle + TAU, TAU)  # Normalize to 0–2π
	var directions : Array[String] = []

	if angle >= 7 * PI / 4 or angle < PI / 8:
		directions.append(player_controls.right)
	elif angle >= PI / 8 and angle < 3 * PI / 8:
		directions.append(player_controls.down)
		directions.append(player_controls.right)
	elif angle >= 3 * PI / 8 and angle < 5 * PI / 8:
		directions.append(player_controls.down)
	elif angle >= 5 * PI / 8 and angle < 7 * PI / 8:
		directions.append(player_controls.down)
		directions.append(player_controls.left)
	elif angle >= 7 * PI / 8 and angle < 9 * PI / 8:
		directions.append(player_controls.left)
	elif angle >= 9 * PI / 8 and angle < 11 * PI / 8:
		directions.append(player_controls.up)
		directions.append(player_controls.left)
	elif angle >= 11 * PI / 8 and angle < 13 * PI / 8:
		directions.append(player_controls.up)
	elif angle >= 13 * PI / 8 and angle < 15 * PI / 8:
		directions.append(player_controls.up)
		directions.append(player_controls.right)

	return directions

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var input_event = InputEventAction.new()
		input_event.action = player_controls.interact
		input_event.pressed = true
		input_event.strength = 1.0
		Input.parse_input_event(input_event)
