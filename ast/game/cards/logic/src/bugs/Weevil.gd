extends CardLogic

static var description : StringName = "When Weevil enters play from your hand, create a copy of it."

func process(_backend_objects : BackendObjectCollection, _effect_resolver : EffectResolver) -> void:
	var my_stats := IStatisticPossessor.id(instance_owner)

	if my_stats.get_statistic(Genesis.Statistic.WAS_JUST_PLAYED): 

		var duped_weevil : ICardInstance = Router.backend.create_card(
			instance_owner.metadata.id,
			instance_owner.player,
			"DupeWeevil-%s" % [Router.backend.get_created_card_number()]
		)

		duped_weevil.logic = CardMetadata.new().logic_script.new(duped_weevil)

		_effect_resolver.request_effect(
			HandAddCardEffect.new(
				instance_owner,
				instance_owner.player,
				duped_weevil
			)
		)