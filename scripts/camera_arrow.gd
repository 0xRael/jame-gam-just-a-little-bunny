extends Sprite2D

@export var game_manager: Node

enum ArrowStates { VISIBLE, HOVERED, HIDDEN }
const visible_x := 8.0
const hidden_x := 0.0
const hovered_x := 16.0

const hover_color : Color = Color("c8c4bd")
const neutral_color : Color = Color("ffffff")
const hidden_color : Color = Color("00000000")

var state = ArrowStates.VISIBLE:
	set(val):
		state = val
		
		var target_x := 8.0
		var time := 0.3
		var color := neutral_color
		match val:
			ArrowStates.HOVERED:
				target_x = hovered_x
				color = hover_color
			ArrowStates.HIDDEN:
				target_x = hidden_x
				color = hidden_color
		
		if not flip_h:
			target_x = 256 - target_x
		
		var current_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		current_tween.tween_property(self, "position", Vector2(target_x, 96), time)
		current_tween.play()
		
		# another tween for color
		current_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		current_tween.tween_property(self, "self_modulate", color, time)
		current_tween.play()

func _ready() -> void:
	if flip_h:
		position.x = visible_x
	else:
		position.x = 256 - visible_x
	
	if game_manager:
		game_manager.game_state_changed.connect(_on_game_state_changed)

func _process(_delta: float) -> void:
	if state == ArrowStates.HIDDEN:
		return
		
	if is_mouse_hovering():
		if state == ArrowStates.VISIBLE:
			state = ArrowStates.HOVERED
	else:
		if state == ArrowStates.HOVERED:
			state = ArrowStates.VISIBLE

func is_mouse_hovering() -> bool:
	if not texture or not game_manager:
		return false
	if flip_h:
		return get_global_mouse_position().x < game_manager.mouse_move_threshold \
		and get_global_mouse_position().x >= 0 \
		or Input.is_action_pressed("ui_left")
	else:
		return get_global_mouse_position().x > 256 - game_manager.mouse_move_threshold \
		and get_global_mouse_position().x <= 256 \
		or Input.is_action_pressed("ui_right")

func _on_game_state_changed(new_state: int):
	match new_state:
		GameManager.GameState.LIVING_ROOM:
			if state == ArrowStates.HIDDEN:
				state = ArrowStates.VISIBLE
		GameManager.GameState.TV:
			if flip_h:
				await get_tree().create_timer(0.3).timeout   
				state = ArrowStates.HIDDEN
			elif state == ArrowStates.HIDDEN:
				state = ArrowStates.VISIBLE
		GameManager.GameState.PANTRY:
			if not flip_h:
				await get_tree().create_timer(0.3).timeout   
				state = ArrowStates.HIDDEN
			elif state == ArrowStates.HIDDEN:
				state = ArrowStates.VISIBLE
		_:
			state = ArrowStates.HIDDEN
