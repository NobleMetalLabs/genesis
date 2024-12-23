class_name PlayedCardEvent
extends Event

var player : Player
var card : ICardInstance

func _init(_player : Player, _card : ICardInstance) -> void:
	self.event_type = "PLAYED_CARD"
	self.player = _player
	self.card = _card

func _to_string() -> String:
	return "PlayedCardEvent(%s, %s)" % [self.player, self.card]
