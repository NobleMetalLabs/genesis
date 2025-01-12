extends CardLogic

static var description : StringName = "Each player draws 2 cards. If there are more than 3 players in the game, you draw a third."

func process(_backend_objects : BackendObjectCollection, _effect_resolver : EffectResolver) -> void:
	if not IStatisticPossessor.id(instance_owner).get_statistic(Genesis.Statistic.WAS_JUST_PLAYED): return
	for player : Player in _backend_objects.players:
		for _i in range(2):
			_effect_resolver.request_effect(
				DeckDrawCardEffect.new(
					instance_owner,
					player,
				)
			)
	if _backend_objects.players.size() > 3:
		_effect_resolver.request_effect(
			DeckDrawCardEffect.new(
				instance_owner,
				instance_owner.player,
			)
		)
