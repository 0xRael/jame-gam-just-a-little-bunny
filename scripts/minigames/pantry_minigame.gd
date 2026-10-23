class_name PantryMinigame
extends MinigameBase

signal target_sequence_updated(new_sequence: Array[Dir])
signal current_step_updated(new_step: int)

enum Dir { UP, DOWN, LEFT, RIGHT }
var target_sequence: Array[Dir] = []
var current_step: int = 0:
	set(value):
		current_step = value
		emit_signal("current_step_updated", value)

func start_minigame() -> void:
	super.start_minigame()
	current_step = 0
	target_sequence.clear()
	
	randomize()
	for i in range(4):
		target_sequence.append(randi() % 4 as Dir)
	emit_signal("target_sequence_updated", target_sequence)
	print("Pantry Lock Sequence Started: ", target_sequence)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	var input_dir: Dir = -1
	if event.is_action_pressed("ui_up"): input_dir = Dir.UP
	elif event.is_action_pressed("ui_down"): input_dir = Dir.DOWN
	elif event.is_action_pressed("ui_left"): input_dir = Dir.LEFT
	elif event.is_action_pressed("ui_right"): input_dir = Dir.RIGHT
	elif event.is_action_pressed("ui_cancel"):
		end_minigame(false) # Canceled out
		return
	
	if input_dir != -1:
		if input_dir == target_sequence[current_step]:
			current_step += 1
			$Press.play()
			if current_step >= target_sequence.size():
				end_minigame(true) # Success!
				$Completed.play()
		else:
			current_step = 0
			emit_signal("minigame_attempt_failed")
			$Error.play()
