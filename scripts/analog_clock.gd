class_name AnalogClock
extends Control

@export var game_manager: GameManager

const COLOR_MAIN := Color("#514d4a")
const COLOR_SHADOW := Color("#5d7298")
const COLOR_BG := Color("#92b5db")
const BORDER_WIDTH: float = 2.0
const HAND_WIDTH: float = 3.0
const SHADOW_DISTANCE: float = 2.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var radius := 14.0
	
	# Draw clock face background and outer pixel border
	draw_circle(center, radius, COLOR_BG)
	draw_arc(center, radius, 0.0, TAU, 16, COLOR_MAIN, BORDER_WIDTH, false)
	
	# Calculate rotation angle based on the day timer
	var progress := 0.0
	if game_manager and game_manager.day_duration_seconds > 0:
		progress = game_manager.day_timer / game_manager.day_duration_seconds
	
	var angle := (progress * TAU) - (TAU / 4.0)
	
	# Clock hand
	var hand_length := radius * 0.65
	var hand_end := center + Vector2(cos(angle), sin(angle)) * hand_length
	draw_line(Vector2(center.x, center.y+SHADOW_DISTANCE),\
		Vector2(hand_end.x, hand_end.y+SHADOW_DISTANCE), \
		COLOR_SHADOW, HAND_WIDTH, false)
	draw_line(center, hand_end, COLOR_MAIN, HAND_WIDTH, false)
	
	# Draw center pin
	draw_rect(Rect2(center - Vector2(1, 1), Vector2(2, 2)), COLOR_MAIN)
