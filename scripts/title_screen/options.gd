extends Control

@onready var master_slider: HSlider = $MasterVol
@onready var music_slider: HSlider = $MusicVol
@onready var sfx_slider: HSlider = $SFXVol
@onready var fullscreen_check: CheckButton = $Fullscreen

func _ready() -> void:
	# Load saved settings and set UI initial values
	var saved := SettingsManager.load_settings()
	master_slider.value = saved["master"]
	music_slider.value = saved["music"]
	sfx_slider.value = saved["sfx"]
	fullscreen_check.button_pressed = saved["fullscreen"]

func _on_master_slider_value_changed(value: float) -> void:
	SettingsManager.set_bus_volume("Master", value)
	_save_all()

func _on_music_slider_value_changed(value: float) -> void:
	SettingsManager.set_bus_volume("Music", value)
	_save_all()

func _on_sfx_slider_value_changed(value: float) -> void:
	SettingsManager.set_bus_volume("SFX", value)
	_save_all()

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	_save_all()

func _save_all() -> void:
	SettingsManager.save_settings(
		master_slider.value,
		music_slider.value,
		sfx_slider.value,
		fullscreen_check.button_pressed
	)
	SettingsManager.load_settings()
