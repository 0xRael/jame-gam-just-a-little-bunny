extends Sprite2D

@export var action_to_listen : String = "ui_up"
@export var unpressed_texture : Texture
@export var pressed_texture : Texture

func _ready():
	var touch := TouchScreenButton.new()
	touch.shape = RectangleShape2D.new()
	touch.shape.size = Vector2(16.0, 22.0)
	touch.action = action_to_listen
	add_child(touch)

func _process(_delta: float) -> void:
	if Input.is_action_pressed(action_to_listen):
		texture = pressed_texture
	else:
		texture = unpressed_texture
