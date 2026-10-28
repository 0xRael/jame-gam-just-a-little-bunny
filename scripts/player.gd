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
const BASE_SANITY_DRAIN := 2.0
var stare_drain_rate := 2.0
const BASE_SANITY_REFILL := 5.0
var tv_refill_rate := 5.0


func set_modifiers(modifiers: Dictionary[String, float]) -> void:
	stare_drain_rate = BASE_SANITY_DRAIN * modifiers["sanity_drain_mult"]
	tv_refill_rate = BASE_SANITY_REFILL * modifiers["sanity_refill_mult"]

func stare(delta: float) -> void:
	sanity -= stare_drain_rate * delta

func watch_tv(delta: float) -> void:
	sanity += tv_refill_rate * delta
