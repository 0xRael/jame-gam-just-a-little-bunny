class_name ViewContainer
extends Control

@export var game_manager: GameManager
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var minigames: Array[MinigameBase] = [$MinigameView]

var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	animation_tree.active = true
	playback = animation_tree.get("parameters/playback")
	
	if game_manager:
		game_manager.game_state_changed.connect(_on_game_state_changed)
		_on_game_state_changed(game_manager.current_state)
		
		game_manager.game_over.connect(_on_game_over)
		game_manager.pantry_lock_changed.connect(_on_pantry_lock_changed)
		game_manager.sink_lock_changed.connect(_on_sink_lock_changed)
	for minigame in minigames:
		minigame.minigame_attempt_failed.connect(_minigame_attempt_failed)

func _on_game_state_changed(new_state: int) -> void:
	match new_state:
		GameManager.GameState.LIVING_ROOM:
			playback.travel("LivingRoom")
		GameManager.GameState.TV:
			playback.travel("TV")
		GameManager.GameState.PANTRY:
			playback.travel("Pantry")
		GameManager.GameState.PANTRY_MINIGAME:
			playback.travel("PantryMinigame")

func _on_pantry_lock_changed(can_use_pantry: bool) -> void:
	$PantryView/Pantry/OpenPantry.visible = not can_use_pantry

func _on_sink_lock_changed(can_use_sink: bool) -> void:
	$PantryView/SinkWater.visible = not can_use_sink

func _on_game_over(reason: String):
	$GameOver.visible = true
	$GameOver/Reason.text = reason

func _minigame_attempt_failed() -> void:
	var shake_intensity: float = 4.0
	var shake_duration: float = 0.2
	var shake_steps: int = 6
	
	var original_pos: Vector2 = position
	
	var tween = create_tween()
	tween.set_parallel(false) # Run sequentially
	
	for i in range(shake_steps):
		# Generate a random offset within the intensity range
		var random_offset := Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(self, "position", original_pos + random_offset, shake_duration / float(shake_steps))
	
	tween.tween_property(self, "position", original_pos, shake_duration / float(shake_steps))
