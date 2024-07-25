class_name UIFullCard
extends Control

@onready var title_label : Label = $"%TITLE-LABEL"
@onready var image_trect : TextureRect = $"%IMAGE"
@onready var type_label : Label = $"%TYPE-LABEL"
@onready var description_label : Label = $"%DESC-LABEL"
@onready var border_component : CardBorder = $"%BORDER-COMPONENT"

var type_to_text : Array[String] = ["Attacker", "Support", "Instant", "Passive", "Leader"]

func set_metadata(metadata : CardMetadata) -> void:
	title_label.text = metadata.name
	image_trect.texture = metadata.image
	type_label.text = type_to_text[metadata.type]
	description_label.text = metadata.logic_script.description
	border_component.set_rarity(metadata.rarity)
