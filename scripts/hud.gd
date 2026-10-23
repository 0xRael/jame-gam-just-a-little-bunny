extends Control

@export var game_manager: Node

@onready var sanity_bar := $SanityBar
@export var hunger_bar : ProgressBar
@onready var patience_bar := $PatienceBar

func _ready() -> void:
	if game_manager:
		game_manager.ready.connect(_set_up)

func _set_up() -> void:
	if game_manager:
		game_manager.player.sanity_changed.connect(_on_player_sanity_changed)
		game_manager.pet.hunger_changed.connect(_on_pet_hunger_changed)
		game_manager.pet.patience_changed.connect(_on_pet_patience_changed)

func _on_player_sanity_changed(value: float) -> void:
	sanity_bar.value = value

func _on_pet_patience_changed(value: float) -> void:
	patience_bar.value = value

func _on_pet_hunger_changed(value: float) -> void:
	hunger_bar.value = value
