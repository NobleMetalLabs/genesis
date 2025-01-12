extends CardLogic

static var description : StringName = "Activate: All of your cards on the field receive Sad and Enlightened. Cannot be activated until played again."

func process(_backend_objects : BackendObjectCollection, _effect_resolver : EffectResolver) -> void:
	var my_stats := IStatisticPossessor.id(instance_owner)
	if my_stats.get_statistic(Genesis.Statistic.WAS_JUST_PLAYED):
		my_stats.set_statistic(Genesis.Statistic.CHARGES, 1)

	if my_stats.get_statistic(Genesis.Statistic.WAS_JUST_ACTIVATED):
		if my_stats.get_statistic(Genesis.Statistic.CHARGES) >= 1:
			my_stats.modify_statistic(Genesis.Statistic.CHARGES, -1)
			for card : ICardInstance in instance_owner.player.cards_on_field:
				_effect_resolver.request_effect(
					ApplyMoodEffect.new(
						instance_owner,
						IMoodPossessor.id(card),
						StatisticMood.SAD(instance_owner),
					)
				)
				_effect_resolver.request_effect(
					ApplyMoodEffect.new(
						instance_owner,
						IMoodPossessor.id(card),
						StatisticMood.ENLIGHTENED(instance_owner),
					)
				)