class_name TaskIcon
extends TextureRect

@export var minigame : PantryMinigame

@export var array_position : int = 0
var up_texture : Texture = preload("res://images/minigames/pantry/up_task.png")
var down_texture : Texture = preload("res://images/minigames/pantry/down_task.png")
var left_texture : Texture = preload("res://images/minigames/pantry/left_task.png")
var right_texture : Texture = preload("res://images/minigames/pantry/right_task.png")

const success_color : Color = Color("96db91")
const neutral_color : Color = Color("ffffff")

func _ready() -> void:
	minigame.target_sequence_updated.connect(_on_target_sequence_updated)
	minigame.current_step_updated.connect(_on_current_step_updated)

func _on_target_sequence_updated(sequence: Array[PantryMinigame.Dir]) -> void:
	if array_position >= len(sequence):
		return
	match sequence[array_position]:
		PantryMinigame.Dir.UP:
			texture = up_texture
		PantryMinigame.Dir.DOWN:
			texture = down_texture
		PantryMinigame.Dir.LEFT:
			texture = left_texture
		PantryMinigame.Dir.RIGHT:
			texture = right_texture

func _on_current_step_updated(step: int) -> void:
	if step > array_position:
		self_modulate = success_color
	else:
		self_modulate = neutral_color
