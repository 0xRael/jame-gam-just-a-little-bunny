class_name Pet
extends RefCounted

signal patience_changed(new_patience: float)
signal hunger_changed(new_hunger: float)

var max_stat := 100.0

var patience := 100.0:
	set(val):
		patience = clamp(val, 0.0, max_stat)
		emit_signal("patience_changed", patience)

var hunger := 100.0:
	set(val):
		hunger = clamp(val, 0.0, max_stat)
		emit_signal("hunger_changed", hunger)

# Drain Rates per second
var hunger_drain_rate := 3.0
var normal_patience_drain := 1.0
var tv_patience_drain := 5.0 # Watching TV drains patience faster
var starving_patience_drain := 15.0 # Rapid drain when hunger hits 0

# Feeding diminishment system
var base_patience_refill := 30.0
var times_fed := 0

func stare(delta: float) -> void:
	_tick_hunger(delta)
	
	# If hunger hits 0, patience drains rapidly even when looked at
	if hunger <= 0.0:
		patience -= starving_patience_drain * delta

func unseen(delta: float) -> void:
	_tick_hunger(delta)
	
	if hunger <= 0.0:
		patience -= starving_patience_drain * delta
	else:
		patience -= normal_patience_drain * delta

func on_watch_tv(delta: float) -> void:
	_tick_hunger(delta)
	patience -= tv_patience_drain * delta

func feed() -> void:
	hunger = max_stat
	
	# The amount of patience restored goes down every time you feed him
	var effective_refill = max(5.0, base_patience_refill - (times_fed * 5.0))
	patience += effective_refill
	times_fed += 1
	
	print("Fed bunny! Restored patience by: ", effective_refill, " (Times fed: ", times_fed, ")")

func _tick_hunger(delta: float) -> void:
	hunger -= hunger_drain_rate * delta
