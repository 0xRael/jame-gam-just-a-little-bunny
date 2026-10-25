extends Control

@export var game_manager: GameManager

@onready var sanity_bar := $SanityBar
@export var hunger_bar : ProgressBar
@export var alt_hunger_bar : TextureProgressBar
@onready var patience_bar := $PatienceBar
@export var thirst_bar : ProgressBar
@export var alt_thirst_bar : TextureProgressBar

@onready var clock := $SubViewport/AnalogClock
var day_just_started := true

var current_note := 0
const MAX_NOTES = [-1, 6, 8, 10]

func _ready() -> void:
	if game_manager:
		game_manager.ready.connect(_set_up)
		clock.game_manager = game_manager
		$Arrows/RightArrow.game_manager = game_manager
		$Arrows/LeftArrow.game_manager = game_manager
		$Arrows/RightArrow._ready()
		$Arrows/LeftArrow._ready()

func _set_up() -> void:
	if game_manager:
		game_manager.player.sanity_changed.connect(_on_player_sanity_changed)
		game_manager.pet.hunger_changed.connect(_on_pet_hunger_changed)
		game_manager.pet.thirst_changed.connect(_on_pet_thirst_changed)
		game_manager.pet.patience_changed.connect(_on_pet_patience_changed)
		game_manager.day_changed.connect(_on_day_changed)
		game_manager.game_paused.connect(_on_game_paused)

func _process(_delta: float) -> void:
	$EscapePercent.text = "Esc: "+str(int(game_manager.pet.escape_chance))+"%"

func _on_player_sanity_changed(value: float) -> void:
	sanity_bar.value = value

func _on_pet_patience_changed(value: float) -> void:
	patience_bar.value = value

func _on_pet_hunger_changed(value: float) -> void:
	hunger_bar.value = value
	alt_hunger_bar.value = value

func _on_day_changed(new_day: int) -> void:
	day_just_started = true
	current_note = MAX_NOTES[min(new_day-1, 3)] +1
	_on_read_notes_pressed()
	if new_day >= 2:
		thirst_bar.show()
		alt_thirst_bar.show()
	if new_day >= 3:
		$EscapePercent.show()

func _on_pet_thirst_changed(value: float) -> void:
	thirst_bar.value = value
	alt_thirst_bar.value = value

func _on_game_paused() -> void:
	$PauseMenu.show()
	$Background.show()
	$PauseMenu/VBoxContainer/Continue.grab_focus()

func _on_continue_pressed() -> void:
	game_manager.unpause()
	$PauseMenu.hide()
	$Background.hide()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_read_notes_pressed() -> void:
	$PauseMenu.hide()
	for i in $Notes.get_children():
		i.hide()
	$Notes.get_child(current_note).show()
	$Background.show()
	$Notes.show()
	$NoteButtons.show()

func _on_next_note_pressed() -> void:
	$Notes.get_child(current_note).hide()
	if current_note == MAX_NOTES[min(game_manager.current_day, 3)]:
		_exit_notes()
		return
	
	current_note += 1
	$Notes.get_child(current_note).show()

func _exit_notes() -> void:
	$Notes.hide()
	$NoteButtons.hide()
	if not day_just_started:
		$PauseMenu.show()
		$PauseMenu/VBoxContainer/Continue.grab_focus()
		return
	day_just_started = false
	$DayStart/Anim.play("default")
	await $DayStart/Anim.animation_finished
	$Background.hide()
	game_manager.unpause()

func _on_prev_note_pressed() -> void:
	if current_note == 0:
		_exit_notes()
		return
	$Notes.get_child(current_note).hide()
	current_note -= 1
	$Notes.get_child(current_note).show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") and $Notes.visible:
		_on_next_note_pressed()
		return
	if event.is_action_pressed("ui_left") and $Notes.visible:
		_on_prev_note_pressed()
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	
	if $Notes.visible:
		_exit_notes()
	elif $PauseMenu.visible:
		_on_continue_pressed()
