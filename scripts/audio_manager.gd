extends Node

@onready var music_bus_idx := AudioServer.get_bus_index("Music")
@export var game_manager: GameManager

# Cutoff frequency targets
const DEFAULT_LOWPASS_CUTOFF := 20000.0
const ALT_LOWPASS_CUTOFF := 5000.0
const DEFAULT_HIGHPASS_CUTOFF := 1.0
const ALT_HIGHPASS_CUTOFF := 500.0

var filter_tween: Tween

func _ready() -> void:	
	if game_manager:
		game_manager.game_state_changed.connect(_on_game_state_changed)
		_on_game_state_changed(game_manager.current_state)

func _on_game_state_changed(state: int) -> void:
	if filter_tween and filter_tween.is_running():
		filter_tween.kill()
		
	filter_tween = create_tween().set_parallel(true)
	
	# Fetch current effects on the Music bus
	var lowpass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(music_bus_idx, 0)
	var highpass: AudioEffectHighPassFilter = AudioServer.get_bus_effect(music_bus_idx, 1)

	match state:
		GameManager.GameState.LIVING_ROOM:
			# Cut highs for dense, tense bunny stare
			filter_tween.tween_property(lowpass, "cutoff_hz", ALT_LOWPASS_CUTOFF, 0.5)
			filter_tween.tween_property(highpass, "cutoff_hz", DEFAULT_HIGHPASS_CUTOFF, 0.5)
			
		GameManager.GameState.TV:
			# Muffle low for TV speaker effect
			filter_tween.tween_property(lowpass, "cutoff_hz", DEFAULT_LOWPASS_CUTOFF, 0.5)
			filter_tween.tween_property(highpass, "cutoff_hz", ALT_HIGHPASS_CUTOFF, 0.5)
			
		_:
			filter_tween.tween_property(lowpass, "cutoff_hz", DEFAULT_LOWPASS_CUTOFF, 0.5)
			filter_tween.tween_property(highpass, "cutoff_hz", DEFAULT_HIGHPASS_CUTOFF, 0.5)
