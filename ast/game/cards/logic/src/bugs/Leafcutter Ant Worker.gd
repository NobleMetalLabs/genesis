extends CardLogic

static var description : StringName = "Whenever the Fungus Garden gains a charge, heal 1 health."

var fungus_garden : ICardInstance = null
var last_seen_num_charges : int = 0

func process(_backend_objects : BackendObjectCollection, _effect_resolver : EffectResolver) -> void:
	var my_stats := IStatisticPossessor.id(instance_owner)
	if my_stats.get_statistic(Genesis.Statistic.IS_ON_FIELD) == false: return
	
	if not fungus_garden:
		for card : ICardInstance in instance_owner.player.cards_on_field:
			if not card: continue
			if card.metadata.name == "Fungus Garden":
				fungus_garden = card
				break
	
	var fungor_stats := IStatisticPossessor.id(fungus_garden)
	var num_charges : int = fungor_stats.get_statistic(Genesis.Statistic.CHARGES)
	if num_charges > last_seen_num_charges:
		_effect_resolver.request_effect(
			ModifyStatisticEffect.new(
				instance_owner,
				IStatisticPossessor.id(instance_owner),
				Genesis.Statistic.HEALTH,
				1
			)
		)
	last_seen_num_charges = num_charges
