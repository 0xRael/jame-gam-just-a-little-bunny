extends Node2D

var progress = 1.0
@export var radius : float
@export var fill_color : Color
@export var segments : int

@export var border_color : Color
@export var border_width : float

func _process(_delta: float) -> void:
	queue_redraw()

func start(time: float) -> void:
	show()
	progress = 1.0
	var tween = create_tween()
	tween.tween_property(self, "progress", 0.0, time)
	await tween.finished
	hide()

func _draw() -> void:
	if progress <= 0.0:
		return
	
	var points : PackedVector2Array = [Vector2(0, 0)]
	var active_segments := maxi(2, int(segments*progress))
	
	var start_angle := -PI/2 # top
	var end_angle : float = start_angle + (progress * TAU)
	
	for i in range(active_segments + 1):
		var t = float(i) / float(active_segments)
		var angle = lerpf(start_angle, end_angle, t)
		
		points.append(Vector2(cos(angle), sin(angle))*radius)
	
	draw_polygon(points, PackedColorArray([fill_color]))
	
	if border_width > 0.0:
		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, active_segments, border_color, border_width, false)
		draw_line(Vector2.ZERO, points[1], border_color, border_width, false)
		draw_line(Vector2.ZERO, points[points.size() - 1], border_color, border_width, false)
