extends Sprite2D

@onready var minigame : PantryMinigame = get_parent()

@export var array_position : int = 0
@export var up_texture : Texture
@export var down_texture : Texture
@export var left_texture : Texture
@export var right_texture : Texture

const success_color : Color = Color("96db91")
const neutral_color : Color = Color("ffffff")

func _ready() -> void:
	minigame.target_sequence_updated.connect(_on_target_sequence_updated)
	minigame.current_step_updated.connect(_on_current_step_updated)

func _on_target_sequence_updated(sequence: Array[PantryMinigame.Dir]) -> void:
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
