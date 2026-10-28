extends Control

signal selection_completed

@export var all_cards: Array[CardData] = []
@export var game_manager: GameManager

func open_selection() -> void:
	all_cards.shuffle()
	
	for i in range(3):
		get_node(str(i)).current_card = all_cards[i]
	
	$AnimationPlayer.play("Start")
	show()


func _on_card_selected(card_data: CardData) -> void:
	$AnimationPlayer.play(str(all_cards.find(card_data)))
	
	game_manager.apply_card_effect(card_data)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Start":
		$AnimationPlayer.play("Stand")
		return
	
	hide()
	emit_signal("selection_completed")
