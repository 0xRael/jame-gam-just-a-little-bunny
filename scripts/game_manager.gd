class_name GameManager
extends Node

enum GameState { LIVING_ROOM, TV, PANTRY, PANTRY_MINIGAME, SINK_MINIGAME, SEARCH_MINIGAME, GAMEOVER }
signal game_state_changed(new_state: GameState)
signal game_over(reason: String)
signal pantry_lock_changed(can_use_pantry: bool)
signal sink_lock_changed(can_use_sink: bool)
signal day_changed(new_day: int)
signal game_paused()

var current_state := GameState.LIVING_ROOM:
	set(val):
		current_state = val
		emit_signal("game_state_changed", val)

@export var mouse_move_threshold: float = 30.
# Debounce/cooldown to prevent rapid flipping back and forth
var input_cooldown: float = 0.0
const COOLDOWN_TIME: float = 0.5 # seconds

var current_day := 1:
	set(val):
		current_day = val
		emit_signal("day_changed", current_day)
var day_duration_seconds := 240.0 # ~4 minutes per day
var day_timer := 0.0

var player: Player
var pet: Pet

var is_game_paused := false:
	set(val):
		is_game_paused = val
		if val:
			emit_signal("game_paused")

@onready var pantry_minigame : PantryMinigame = $ViewContainer/MinigameView
@onready var sink_minigame : SinkMinigame = $ViewContainer/SinkMinigameView
@onready var search_minigame : SearchMinigame = $ViewContainer/SearchMinigameView

var can_use_pantry := true:
	set(val):
		can_use_pantry = val
		emit_signal("pantry_lock_changed", val)
var can_use_sink := true:
	set(val):
		can_use_sink = val
		emit_signal("sink_lock_changed", val)


func _ready() -> void:
	player = Player.new()
	pet = Pet.new()
	
	pantry_minigame.minigame_completed.connect(_on_pantry_minigame_completed)
	sink_minigame.minigame_completed.connect(_on_sink_minigame_completed)
	search_minigame.minigame_completed.connect(_on_search_minigame_completed)
	pet.has_escaped.connect(_on_pet_escaped)
	
	await get_tree().create_timer(0.5).timeout
	is_game_paused = true
	check_day_mechanics()
	emit_signal("day_changed", current_day)

func _process(delta: float) -> void:
	if current_state == GameState.GAMEOVER or is_game_paused or current_state == GameState.SEARCH_MINIGAME:
		return
		
	day_timer += delta
	
	if input_cooldown > 0.0:
		input_cooldown -= delta
	
	match current_state:
		GameState.LIVING_ROOM:
			player.stare(delta)
			pet.stare(delta)
		GameState.TV:
			player.watch_tv(delta)
			pet.on_watch_tv(delta)
		GameState.GAMEOVER:
			pass
		_:
			pet.unseen(delta)
	
	check_game_over()
	
	if input_cooldown <= 0.0:
		handle_input()
	
	if day_timer >= day_duration_seconds:
		advance_day()

func check_game_over() -> void:
	if player.sanity <= 0.0:
		trigger_game_over("You've gone Insane! Don't look at the bunny too long")
	elif pet.patience <= 0.0:
		trigger_game_over("The Bunny lost Patience and decided to kill you...")

func trigger_game_over(reason: String) -> void:
	current_state = GameState.GAMEOVER
	emit_signal("game_over", reason)

func handle_input() -> void:
	if not get_window().has_focus():
		return
	
	var viewport_size := Vector2(256, 192) # Yes idk how to get it dinamically just don't tell anyone
	var mouse_pos := get_viewport().get_mouse_position()
	
	var is_mouse_inside := Rect2(Vector2.ZERO, viewport_size).has_point(mouse_pos)
	
	# Detect left/right action from keyboard OR mouse edge
	var triggered_left: bool = Input.is_action_pressed("ui_left") or (is_mouse_inside and mouse_pos.x <= mouse_move_threshold)
	var triggered_right: bool = Input.is_action_pressed("ui_right") or (is_mouse_inside and mouse_pos.x >= viewport_size.x - mouse_move_threshold)
	
	if Input.is_action_just_pressed("ui_cancel"):
		is_game_paused = true
		return
	
	match current_state:
		GameState.LIVING_ROOM:
			if triggered_left:
				current_state = GameState.TV
				input_cooldown = COOLDOWN_TIME
			elif triggered_right:
				current_state = GameState.PANTRY
				input_cooldown = COOLDOWN_TIME
				
		GameState.TV:
			if triggered_right:
				current_state = GameState.LIVING_ROOM
				input_cooldown = COOLDOWN_TIME
				
		GameState.PANTRY:
			if triggered_left:
				current_state = GameState.LIVING_ROOM
				input_cooldown = COOLDOWN_TIME
			elif can_use_pantry and (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("minigame1")):
				current_state = GameState.PANTRY_MINIGAME
				pantry_minigame.start_minigame()
			elif can_use_sink and pet.enable_thirst and Input.is_action_pressed("minigame2"):
				current_state = GameState.SINK_MINIGAME
				sink_minigame.start_minigame()

func advance_day() -> void:
	is_game_paused = 1
	current_day += 1
	day_timer = 0.0
	print("Advanced to day: ", current_day)
	check_day_mechanics()

func check_day_mechanics() -> void:
	if current_day >= 2:
		# Enable thirst mechanics on day 2
		pet.enable_thirst = true
	if current_day >= 3:
		pet.enable_escape = true

func _on_pantry_minigame_completed(success: bool) -> void:
	current_state = GameState.PANTRY
	if success:
		pet.feed()
		can_use_pantry = false
		await get_tree().create_timer(10.0).timeout 
		can_use_pantry = true

func _on_sink_minigame_completed(success: bool) -> void:
	current_state = GameState.PANTRY
	if success:
		pet.drink()
		can_use_sink = false
		await get_tree().create_timer(10.0).timeout
		can_use_sink = true

func _on_pet_escaped() -> void:
	current_state = GameState.SEARCH_MINIGAME
	search_minigame.start_minigame()

func _on_search_minigame_completed(success: bool) -> void:
	current_state = GameState.LIVING_ROOM
	if not success:
		pet.patience = pet.patience/2
		player.sanity = player.sanity/2
	else:
		pet.patience += 20.0
		player.sanity += 20.0

func unpause() -> void:
	is_game_paused = false
