class_name Pet
extends RefCounted

signal patience_changed(new_patience: float)
signal hunger_changed(new_hunger: float)
signal thirst_changed(new_hunger: float)
signal has_escaped()

var max_stat := 100.0

var patience := 100.0:
	set(val):
		patience = clamp(val, 0.0, max_stat)
		emit_signal("patience_changed", patience)

var hunger := 100.0:
	set(val):
		hunger = clamp(val, 0.0, max_stat)
		emit_signal("hunger_changed", hunger)

var thirst := 100.0:
	set(val):
		thirst = clamp(val, 0.0, max_stat)
		emit_signal("thirst_changed", thirst)

# Drain Rates per second
const HUNGER_BASE_DRAIN := 3.5
var hunger_drain_rate := 3.5
const THIRST_BASE_DRAIN := 1.5
var thirst_drain_rate := 1.5
const PATIENCE_BASE_DRAIN := 1.0
var normal_patience_drain := 1.0
var tv_patience_drain := 1.5 # Watching TV drains patience faster
var starving_patience_drain := 10.0 # Rapid drain when hunger hits 0
const STARE_PATIENCE_BASE_REFILL := 1.0
var stare_patience_refill := 1.0

# Feeding diminishment system
var base_patience_refill := 30.0
var times_fed := 0

var enable_thirst := false
var stare_timer := 0.0

var enable_escape := false
const BASE_ESCAPE_CHANCE := 0.0
var escape_chance := 0.0
const BASE_ESCAPE_CHANCE_GROWTH := 0.5
var escape_chance_growth := 0.5
const ESCAPE_TIMER := 30.0
var current_timer_length := 30.0
var timer_to_check := 30.0

func stare(delta: float) -> void:
	_tick_hunger(delta)
	
	stare_timer += delta
	
	# If hunger hits 0, patience drains rapidly even when looked at
	if hunger <= 0.0:
		patience -= starving_patience_drain * delta
	elif stare_timer >= 5.0:
		patience += stare_patience_refill * delta

func set_modifiers(modifiers: Dictionary[String, float]) -> void:
	thirst_drain_rate = THIRST_BASE_DRAIN * modifiers["thirst_drain_mult"]
	hunger_drain_rate = HUNGER_BASE_DRAIN * modifiers["hunger_drain_mult"]
	normal_patience_drain = PATIENCE_BASE_DRAIN * modifiers["patience_drain_mult"]
	stare_patience_refill = STARE_PATIENCE_BASE_REFILL * modifiers["stare_patience_refill_mult"]
	escape_chance_growth = BASE_ESCAPE_CHANCE_GROWTH * modifiers["escape_chance_growth_mult"]
	current_timer_length = ESCAPE_TIMER * modifiers["escape_timer_mult"]

func unseen(delta: float) -> void:
	_tick_hunger(delta)
	
	stare_timer = 0.0
	
	if hunger <= 0.0 or thirst <= 0.0:
		patience -= starving_patience_drain * delta
	else:
		patience -= normal_patience_drain * delta

func on_watch_tv(delta: float) -> void:
	_tick_hunger(delta)
	patience -= tv_patience_drain * normal_patience_drain * delta

func feed() -> void:
	hunger = max_stat
	
	# The amount of patience restored goes down every time you feed him
	var effective_refill = max(5.0, base_patience_refill - (times_fed * 5.0))
	patience += effective_refill
	times_fed += 1

func drink() -> void:
	thirst = max_stat

func _tick_hunger(delta: float) -> void:
	hunger -= hunger_drain_rate * delta
	if enable_thirst:
		thirst -= thirst_drain_rate * delta
	if not enable_escape:
		return
	
	escape_chance += escape_chance_growth * delta
	timer_to_check -= delta
	if timer_to_check <= 0:
		timer_to_check = current_timer_length
		
		print("Escape chance when rolling: ", escape_chance)
		randomize()
		if randf_range(0.0, 100.0) < escape_chance:
			emit_signal("has_escaped")
			escape_chance = BASE_ESCAPE_CHANCE
