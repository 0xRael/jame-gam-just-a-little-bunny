class_name CardData
extends Resource

@export var card_title: String
@export var modifiers: Dictionary[String, float]

const GOOD_COLOR := "009c89"
const BAD_COLOR := "8e5777"

const GOOD_EFFECTS : Array[String] = [
	"stare_patience_refill_mult",
	"sanity_refill_mult"
]

func get_description() -> String:
	var desc = ""
	var first = true
	
	for key in modifiers:
		if !first:
			desc += "[br]\n"
		first = false
		
		var val = modifiers[key]
		var readable_name = format_stat_name(key)
		
		var is_good = key in GOOD_EFFECTS
		var color = BAD_COLOR
		if is_good == (val > 1.0):
			color = GOOD_COLOR
		
		desc += "%s [wave][color=%s]x%.1f[/color][/wave]" % [readable_name, color, val]
	
	return desc

func format_stat_name(key: String) -> String:
	match key:
		"thirst_drain_mult": return "Thirst Drain"
		"hunger_drain_mult": return "Hunger Drain"
		"patience_drain_mult": return "Patience Drain"
		"stare_patience_refill_mult": return "Patience Refill"
		"escape_chance_growth_mult": return "Escape Chance"
		"escape_timer_mult": return "Escape Timer"
		
		"sanity_drain_mult": return "Sanity Drain"
		"sanity_refill_mult": return "Sanity Refill"
		
		"pantry_digits_mult": return "Pantry Digits"
		
		"sink_speed_mult": return "Sink Speed"
		"sink_friction_mult": return "Sink Friction"
		_: return key.replace("_", " ").capitalize()
