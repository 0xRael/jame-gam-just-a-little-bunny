class_name AnalogClock
extends TextureRect

@export var game_manager: GameManager

const COLOR_MAIN := Color("#514d4a")
const COLOR_SHADOW := Color("#dcaf91")
const COLOR_SHADOW_HOVER := Color("#5d719a")
const BORDER_WIDTH: float = 2.0
const HAND_WIDTH: float = 3.0
const SHADOW_DISTANCE: float = 2.0

@export var normal_texture : Texture
@export var hover_texture : Texture
var is_hover := false

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var radius := 10.0
	
	# Calculate rotation angle based on the day timer
	var progress := 0.0
	if game_manager and game_manager.day_duration_seconds > 0:
		progress = game_manager.day_timer / game_manager.day_duration_seconds
	
	var angle := (progress * TAU) - (TAU / 4.0)
	
	# Clock hand
	var hand_length := radius
	var hand_end := center + Vector2(cos(angle), sin(angle)) * hand_length
	var color := COLOR_SHADOW
	if is_hover:
		color = COLOR_SHADOW_HOVER
	draw_line(Vector2(center.x, center.y+SHADOW_DISTANCE),\
		Vector2(hand_end.x, hand_end.y+SHADOW_DISTANCE), \
		color, HAND_WIDTH, false)
	draw_line(center, hand_end, COLOR_MAIN, HAND_WIDTH, false)
	
	# Draw center pin
	draw_rect(Rect2(center - Vector2(1, 1), Vector2(2, 2)), COLOR_MAIN)


func _on_mouse_entered() -> void:
	is_hover = true
	texture = hover_texture

func _on_mouse_exited() -> void:
	is_hover = false
	texture = normal_texture
