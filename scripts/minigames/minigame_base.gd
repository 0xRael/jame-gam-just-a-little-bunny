class_name MinigameBase
extends Control

# Every minigame will inherit and emit this signal when finished
signal minigame_completed(success: bool)
signal minigame_attempt_failed
var is_active: bool = false

# Overridden by child classes to initialize their unique puzzle
func start_minigame() -> void:
	is_active = true
	show()

# Overridden or handled for cleanup
func end_minigame(success: bool) -> void:
	is_active = false
	hide()
	minigame_completed.emit(success)
