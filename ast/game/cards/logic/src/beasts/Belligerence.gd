extends CardLogic

static var description : StringName = "Targeted creature receives Rage."

func process(_backend_objects : BackendObjectCollection, _effect_resolver : EffectResolver) -> void:
	var my_stats := IStatisticPossessor.id(instance_owner)
	if not my_stats.get_statistic(Genesis.Statistic.HAS_TARGET): return
	var target : ICardInstance = my_stats.get_statistic(Genesis.Statistic.TARGET)
	_effect_resolver.request_effect(
		ApplyMoodEffect.new(
			instance_owner,
			IMoodPossessor.id(target),
			StatisticMood.RAGE(instance_owner)
		)
	)