class_name Player
extends RefCounted

signal sanity_changed(new_sanity: float)

var max_sanity := 100.0:
	set(val):
		max_sanity = val
		sanity = clamp(sanity, 0.0, max_sanity)

var sanity := 100.0:
	set(val):
		sanity = clamp(val, 0.0, max_sanity)
		emit_signal("sanity_changed", sanity)

# Rates per second
var stare_drain_rate := 5.0
var tv_refill_rate := 10.0

func stare(delta: float) -> void:
	sanity -= stare_drain_rate * delta

func watch_tv(delta: float) -> void:
	sanity += tv_refill_rate * delta
