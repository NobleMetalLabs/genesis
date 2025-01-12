extends CardLogic

static var description : StringName = "Start the game with a Fungus Garden, which is untargetable by opponent creatures, unkillable, and costs no energy."

var fungus_garden : ICardInstance = null
var damage_count : int = 0

func process(_backend_objects : BackendObjectCollection, _effect_resolver : EffectResolver) -> void:
	var my_stats := IStatisticPossessor.id(instance_owner)
	if fungus_garden != null: return

	fungus_garden = Router.backend.create_card(
		CardDB.get_id_by_name("Fungus Garden"),
		instance_owner.player,
		"Fungus Garden-%s" % [Router.backend.get_created_card_number()]
	)

	var fungor_stats := IStatisticPossessor.id(fungus_garden)

	fungor_stats.set_statistic(Genesis.Statistic.ENERGY, 0)
	fungor_stats.set_statistic(Genesis.Statistic.CAN_BE_TARGETED_FRIENDLIES_ONLY, true)
	fungor_stats.set_statistic(Genesis.Statistic.CAN_BE_KILLED, false)
	fungor_stats.set_statistic(Genesis.Statistic.POSITION, my_stats.get_statistic(Genesis.Statistic.POSITION) + Vector2(100, 0))

	_effect_resolver.request_effect(
		CreatureSpawnEffect.new(
			instance_owner,
			fungus_garden
		)
	)
