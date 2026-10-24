extends Control

@onready var animation_player = $AnimationPlayer

func _on_ready() -> void:
	await get_tree().create_timer(0.3).timeout
	$MainButtons/Play.grab_focus()

func _on_play_pressed() -> void:
	$Play.visible = true
	$MainButtons.visible = false
	$Play/NewGame.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	animation_player.play("MainMenu2Options")
	$Options/MasterVol.grab_focus()

func _on_back_pressed() -> void:
	animation_player.play("Options2MainMenu")
	$MainButtons/Play.grab_focus()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "End":
		return
	if Global.target_day == 1:
		get_tree().change_scene_to_file("res://scenes/Intro.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_credits_pressed() -> void:
	animation_player.play("MainMenu2Credits")

func _on_credits_back_pressed() -> void:
	animation_player.play("Credits2MainMenu")
	$MainButtons/Play.grab_focus()


func _on_play_back_pressed() -> void:
	$Play.visible = false
	$MainButtons.visible = true
	$MainButtons/Play.grab_focus()


func _on_new_game_pressed(day: int) -> void:
	Global.target_day = day
	animation_player.play("End")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $Options.visible:
			_on_back_pressed()
		elif $Credits.visible:
			_on_credits_back_pressed()
		elif $Play.visible:
			_on_play_back_pressed()
