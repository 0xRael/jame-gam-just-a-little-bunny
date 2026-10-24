extends Control

var current_step := 1
var finish_step := 3

func _ready():
	$Button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		next()

func next():
	if current_step == finish_step:
		$AnimationPlayer.play("End")
		return
	current_step += 1
	$AnimationPlayer.play(str(current_step))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "End":
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_button_pressed() -> void:
	next()
