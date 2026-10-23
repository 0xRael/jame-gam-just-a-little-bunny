extends Control

@export var game_manager: Node

@onready var sanity_bar := $SanityBar
@export var hunger_bar : ProgressBar
@export var alt_hunger_bar : TextureProgressBar
@onready var patience_bar := $PatienceBar
@export var thirst_bar : ProgressBar
@export var alt_thirst_bar : TextureProgressBar

const DAY_TEXTS : Array[String] = [
	"",
	"Check the bunny's hunger bar, get food from the Pantry (right side) when needed.",
	"Your bunny can now feel thirsty! Grab water from the Sink before the bar gets low.",
	"Nothing implemented for this day yet!",
]

func _ready() -> void:
	if game_manager:
		game_manager.ready.connect(_set_up)

func _set_up() -> void:
	if game_manager:
		game_manager.player.sanity_changed.connect(_on_player_sanity_changed)
		game_manager.pet.hunger_changed.connect(_on_pet_hunger_changed)
		game_manager.pet.thirst_changed.connect(_on_pet_thirst_changed)
		game_manager.pet.patience_changed.connect(_on_pet_patience_changed)
		game_manager.day_changed.connect(_on_day_changed)

func _on_player_sanity_changed(value: float) -> void:
	sanity_bar.value = value

func _on_pet_patience_changed(value: float) -> void:
	patience_bar.value = value

func _on_pet_hunger_changed(value: float) -> void:
	hunger_bar.value = value
	alt_hunger_bar.value = value

func _on_day_changed(new_day: int) -> void:
	$NewDay/Title.text = "Day #" + str(new_day) + "!"
	if new_day < len(DAY_TEXTS):
		$NewDay/Reason.text = DAY_TEXTS[new_day]
	$NewDay.show()
	if new_day == 2:
		thirst_bar.show()
		alt_thirst_bar.show()

func _on_pet_thirst_changed(value: float) -> void:
	thirst_bar.value = value
	alt_thirst_bar.value = value

func _on_ok_pressed() -> void:
	$NewDay.hide()
