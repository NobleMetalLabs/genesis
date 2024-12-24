extends CardLogic

static var description : StringName = "Target creature with less than 5 health. Creature dies, and their health count is added to Leech's owners health."

func _register_processing_steps() -> void:
	game_access.epsm.register_event_processing_step(
		EventProcessingStep.new(SingleCardTargetGroup.new(owner), "ENTERED_FIELD", owner, ATTEMPT_INSTANT_CAST, 
			EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.POSTEVENT).RARITY_FROM_CARD(owner)
	))
	game_access.epsm.register_event_processing_step(
		EventProcessingStep.new(SingleCardTargetGroup.new(owner), "TARGETED", owner, ATTEMPT_INSTANT_CAST, 
			EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.POSTEVENT).RARITY_FROM_CARD(owner)
	))

func ATTEMPT_INSTANT_CAST(_event : Event) -> void:
	var my_stats := IStatisticPossessor.id(owner)
	var is_on_field : bool = my_stats.get_statistic(Genesis.Statistic.IS_ON_FIELD)
	var target : ICardInstance = my_stats.get_statistic(Genesis.Statistic.TARGET)
	
	if is_on_field and target != null: LEECH(target)

func LEECH(target : ICardInstance) -> void:
	var target_health : int = IStatisticPossessor.id(target).get_statistic(Genesis.Statistic.HEALTH)
	if target_health >= 5: return
	
	game_access.request_event(
		KilledEvent.new(owner, target)
	)
	game_access.request_event(
		SetStatisticEvent.modify(owner.player.leader, Genesis.Statistic.HEALTH, target_health)
	)
	game_access.request_event(
		KilledEvent.new(owner, owner)
	)
