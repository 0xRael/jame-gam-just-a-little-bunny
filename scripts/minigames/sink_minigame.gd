class_name SinkMinigame
extends MinigameBase

# Rotation in radians
var target_rotation : float:
	set(val):
		target_rotation = val
		$OuterWheel.rotation = target_rotation
var current_rotation : float:
	set(val):
		current_rotation = fmod(fmod(val, PI * 2) + PI * 2, PI * 2)
		$Wheel.rotation = current_rotation

const ACCELERATION := 0.2
const FRICTION := 0.05
const SPEED_THRESHOLD := 0.005
const DIST_THRESHOLD := 0.2
var speed := 0.0

func start_minigame() -> void:
	super.start_minigame()
	
	randomize()
	target_rotation = randf_range(PI, PI*2)
	current_rotation = randf_range(0, PI)
	print("Target rotation: ", target_rotation, " Starting rotation: ", current_rotation)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if Input.is_action_pressed("ui_cancel"):
		end_minigame(false) # Canceled out
		speed = 0
		return
	
	if Input.is_action_pressed("ui_down"):
		speed += ACCELERATION * delta
	elif Input.is_action_pressed("ui_up"):
		speed -= ACCELERATION * delta
	elif speed > FRICTION * delta:
		speed -= FRICTION * delta
	elif speed < FRICTION * -delta:
		speed += FRICTION * delta
	else:
		speed = 0
	
	if speed != 0:
		current_rotation += speed
	
	if abs(current_rotation-target_rotation) < DIST_THRESHOLD \
		and abs(speed) < SPEED_THRESHOLD:
			end_minigame(true) # Success!
			speed = 0
