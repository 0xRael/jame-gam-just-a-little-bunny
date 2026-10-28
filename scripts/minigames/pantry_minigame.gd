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
const DEFAULT_ARRAY_LENGTH := 4
var array_length := 4:
	set(val):
		array_length = val

const ARROW_SIZE := 16

var arrow_tween : Tween
@onready var arrow_container : Control = $Arrows/Control/HBoxContainer
#const ARROW_SCRIPT := preload("res://scripts/minigames/pantry/task_icon.gd")

func set_modifiers(modifiers: Dictionary[String, float]):
	array_length = int(DEFAULT_ARRAY_LENGTH * modifiers["pantry_digits_mult"])

func start_minigame() -> void:
	super.start_minigame()
	update_textures()
	current_step = 0
	target_sequence.clear()
	
	randomize()
	for i in range(array_length):
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
			var target_x : float
			if array_length-current_step > 3:
				target_x = (current_step-1) * -ARROW_SIZE
			else:
				target_x = (array_length-4) * -ARROW_SIZE
			animate_arrow_container(target_x)
			$Press.play()
			if current_step >= target_sequence.size():
				end_minigame(true) # Success!
				$Completed.play()
		else:
			current_step = 0
			animate_arrow_container(0.0)
			emit_signal("minigame_attempt_failed")
			$Error.play()

func animate_arrow_container(target_x: float) -> void:
	if arrow_tween and arrow_tween.is_running():
		arrow_tween.kill()
	
	arrow_tween = create_tween().set_trans(Tween.TRANS_QUAD). set_ease(Tween.EASE_OUT)
	arrow_tween.tween_property(arrow_container, "position:x", target_x, 0.15)

func update_textures():
	arrow_container.position.x = 0
	var i = 0
	for child in arrow_container.get_children():
		if i >= array_length:
			child.queue_free()
		i += 1
	while i < array_length:
		var new = TaskIcon.new()
		new.array_position = i
		new.minigame = self
		arrow_container.add_child(new)
		i+=1
