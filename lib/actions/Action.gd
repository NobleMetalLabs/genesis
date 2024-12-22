class_name Action
extends Serializeable

# TODO: (like years from now) replays and huh button.

var player_peer_id : int = MultiplayerManager.get_peer_id()
var gametick : int

func _init() -> void:
	assert(false, "Action is an abstract class and should not be instantiated.")

# func to_effect() -> Effect:
# 	assert(false, "Abstract method to_effect() is not implemented in a class extending action.")
# 	return null
