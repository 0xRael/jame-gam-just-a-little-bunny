class_name SearchMinigame
extends MinigameBase

const MAX_TIMER := 5.0 # In seconds
var timer : float

@onready var timer_bar : ProgressBar = $Panel/ProgressBar
@onready var grid : GridContainer = $Panel/Control/Grid
const STAGE_GRID_SIZES = [4, 5, 7]
const STAGE_CHOSEN_TEXTURE = [
	preload("res://images/minigames/search/green.png"),
	preload("res://images/minigames/search/orange.png"),
	preload("res://images/minigames/search/bunny.png")
]
const STAGE_TEXTURE = [
	preload("res://images/minigames/search/red.png"),
	preload("res://images/minigames/search/blue.png"),
	preload("res://images/minigames/search/white.png")
]
var stage := 0
var chosen_n := 0

func fill_grid():
	for i in grid.get_children():
		i.queue_free()
	
	var columns : int = STAGE_GRID_SIZES[stage]
	var chosen_texture : Texture = STAGE_CHOSEN_TEXTURE[stage]
	var normal_texture : Texture = STAGE_TEXTURE[stage]
	
	grid.columns = columns
	randomize()
	chosen_n = randi_range(0, columns*columns-1)
	
	for i in range(columns*columns):
		var box = Button.new()
		box.icon = normal_texture
		if i == chosen_n:
			box.icon = chosen_texture
			box.connect("pressed", _on_chosen_pressed)
		else:
			box.connect("pressed", _on_wrong_pressed)
		grid.add_child(box)

# Show a message first so the user can prepare before timers start
func start_minigame() -> void:
	stage = 0
	timer = MAX_TIMER
	timer_bar.max_value = MAX_TIMER
	
	$Panel.visible = false
	$Message.visible = true

func _on_start_pressed() -> void:
	$Message.visible = false
	$Panel.visible = true
	
	super.start_minigame()
	fill_grid()

func _process(delta: float) -> void:
	if not is_active:
		return
	
	timer -= delta
	timer_bar.value = timer
	if timer <= 0:
		end_minigame(false)

func _on_chosen_pressed() -> void:
	$Press.play()
	timer = MAX_TIMER
	if stage >= len(STAGE_GRID_SIZES)-1:
		end_minigame(true)
		return
	stage += 1
	fill_grid()

func _on_wrong_pressed() -> void:
	emit_signal("minigame_attempt_failed")
	$Error.play()
