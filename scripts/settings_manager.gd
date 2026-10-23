extends Node

const SAVE_PATH := "user://settings.cfg"
var config := ConfigFile.new()

func _ready() -> void:
	load_settings()

func set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		var db_value := linear_to_db(clamp(linear_value, 0.0001, 1.0))
		AudioServer.set_bus_volume_db(bus_idx, db_value)
		# Mute if slider 0
		AudioServer.set_bus_mute(bus_idx, linear_value <= 0.0001)

func save_settings(master_vol: float, music_vol: float, sfx_vol: float, fullscreen: bool) -> void:
	config.set_value("audio", "master", master_vol)
	config.set_value("audio", "music", music_vol)
	config.set_value("audio", "sfx", sfx_vol)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SAVE_PATH)

func load_settings() -> Dictionary:
	var err := config.load(SAVE_PATH)
	var settings := {
		"master": 0.8,
		"music": 0.8,
		"sfx": 0.8,
		"fullscreen": false
	}
	
	if err == OK:
		settings["master"] = config.get_value("audio", "master", 0.8)
		settings["music"] = config.get_value("audio", "music", 0.8)
		settings["sfx"] = config.get_value("audio", "sfx", 0.8)
		settings["fullscreen"] = config.get_value("video", "fullscreen", false)
	
	# Apply loaded values
	set_bus_volume("Master", settings["master"])
	set_bus_volume("Music", settings["music"])
	set_bus_volume("SFX", settings["sfx"])
	
	var mode := DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	return settings
