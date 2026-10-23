extends Node

@export var parent : Node
@export var click_sfx : AudioStreamPlayer
@export var hover_sfx : AudioStreamPlayer

## Connects click sound effects to buttons when the control becomes ready.
func _ready() -> void:
	_connect_buttons_recursive(parent)

## Recursively adds a on_pressed SFX to all buttons
func _connect_buttons_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton:
			child.pressed.connect(click_sfx.play)
			#child.mouse_entered.connect(hover_sfx.play)
		if child is HSlider:
			print("heres")
			child.drag_ended.connect(_drag_ended)
		
		if child.get_child_count() > 0:
			_connect_buttons_recursive(child)

func _drag_ended(_ignore_param) -> void:
	click_sfx.play()
