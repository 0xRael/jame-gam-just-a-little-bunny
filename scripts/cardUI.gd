extends Node2D

signal card_selected(card_data: CardData)

@onready var title_label: Label = $Title
@onready var description: RichTextLabel = $Description

var current_card: CardData:
	set(val):
		current_card = val
		title_label.text = current_card.card_title
		description.text = current_card.get_description()

func _on_pressed() -> void:
	card_selected.emit(current_card)
