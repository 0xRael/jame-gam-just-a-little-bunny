extends Sprite2D

@export var game_manager: GameManager
@export var sky_gradient: Gradient

func _process(delta: float) -> void:
	var progress := 0.0
	if game_manager and game_manager.day_duration_seconds > 0:
		progress = game_manager.day_timer / game_manager.day_duration_seconds
	
	self_modulate = sky_gradient.sample(progress)
