class_name ViewContainer
extends Control

@export var game_manager: GameManager
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var minigames: Array[MinigameBase] = [$MinigameView]

@onready var game_over_screen : CanvasItem = $"../GameOver"
const GAME_OVER_SCREENS : Dictionary = {
	"patience": preload("res://images/game-over.png"),
	"sanity": preload("res://images/game-over-sanity.png")
}

var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	animation_tree.active = true
	playback = animation_tree.get("parameters/playback")
	
	if game_manager:
		game_manager.game_state_changed.connect(_on_game_state_changed)
		_on_game_state_changed(game_manager.current_state)
		game_manager.day_changed.connect(_on_day_changed)
		
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
		GameManager.GameState.SEARCH_MINIGAME:
			$SearchMinigameView.visible = true

func _on_pantry_lock_changed(can_use_pantry: bool) -> void:
	$PantryView/Pantry/OpenPantry.visible = not can_use_pantry

func _on_sink_lock_changed(can_use_sink: bool) -> void:
	$PantryView/SinkWater.visible = not can_use_sink

func _on_game_over(reason: String):
	game_over_screen.texture = GAME_OVER_SCREENS[reason]
	game_over_screen.modulate = Color(0, 0, 0, 0)
	game_over_screen.visible = true
	game_over_screen.get_node(reason).visible = true
	var new_tween = create_tween()
	new_tween.tween_property(game_over_screen, "modulate", Color(1, 1, 1, 1), 1.0)
	
	await get_tree().create_timer(5.0).timeout
	game_manager.lost = true
	game_manager.animation_transition.play("End")

func _minigame_attempt_failed() -> void:
	if not Global.screenshake:
		return
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

const CABINET_POS := Vector2(144, 75)
const SINK_POS := Vector2(220, 132)
const DIST_THRESHOLD := 40.0

func _process(_delta: float) -> void:
	if game_manager.current_state != game_manager.GameState.PANTRY:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	$PantryView/CabinetBorder.visible =  game_manager.can_use_pantry and mouse_pos.distance_to(CABINET_POS) < DIST_THRESHOLD
	$PantryView/SinkBorder.visible =  game_manager.current_day >= 2 and game_manager.can_use_sink and mouse_pos.distance_to(SINK_POS) < DIST_THRESHOLD

func _on_day_changed(new_day: int) -> void:
	$TVView/Content.play(str(new_day))
