extends Control

@onready var animation_player = $AnimationPlayer

func _on_play_pressed() -> void:
	animation_player.play("End")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	animation_player.play("MainMenu2Options")

func _on_back_pressed() -> void:
	animation_player.play("Options2MainMenu")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "End":
		get_tree().change_scene_to_file("res://scenes/main.tscn")
