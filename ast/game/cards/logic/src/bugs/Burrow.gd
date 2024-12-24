extends CardLogic

static var description : StringName = "Attacker target burrows. While burrowed, it cannot be attacked, but may only make attacks against Supports. It remains burrowed until it has made 3 attacks."

var burrowers_to_attacks : Dictionary = {}

func _register_processing_steps() -> void:
	game_access.epsm.register_event_processing_step(
		EventProcessingStep.new(SingleCardTargetGroup.new(owner), "ENTERED_FIELD", self, ATTEMPT_INSTANT_CAST, 
			EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.POSTEVENT).RARITY_FROM_CARD(owner)
	))
	game_access.epsm.register_event_processing_step(
		EventProcessingStep.new(SingleCardTargetGroup.new(owner), "TARGETED", self, ATTEMPT_INSTANT_CAST, 
			EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.POSTEVENT).RARITY_FROM_CARD(owner)
	))

func ATTEMPT_INSTANT_CAST(_event : Event) -> void:
	var my_stats := IStatisticPossessor.id(owner)
	var is_on_field : bool = my_stats.get_statistic(Genesis.Statistic.IS_ON_FIELD)
	var target : ICardInstance = my_stats.get_statistic(Genesis.Statistic.TARGET)
	
	if not is_on_field or target == null: return
	if target.metadata.type != Genesis.CardType.ATTACKER: return
	if burrowers_to_attacks.has(target): return
	
	burrowers_to_attacks[target] = 0
	
	game_access.epsm.register_event_processing_step(
		EventProcessingStep.new(SingleCardTargetGroup.new(target), "WAS_ATTACKED", self, BLOCK_BURROWER_ATTACKED, 
			EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.PREEVENT).RARITY_FROM_CARD(owner)
	))
	
	game_access.epsm.register_event_processing_step(
		EventProcessingStep.new(SingleCardTargetGroup.new(target), "ATTACKED", self, HANDLE_BURROWER_ATTACKS, 
			EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.PREEVENT).RARITY_FROM_CARD(owner)
	))
	
	game_access.request_event(
		KilledEvent.new(owner, owner)
	)

func BLOCK_BURROWER_ATTACKED(event : WasAttackedEvent) -> void:
	if not burrowers_to_attacks.has(event.card): return
	event.has_failed = true

func HANDLE_BURROWER_ATTACKS(event : AttackedEvent) -> void:
	if not burrowers_to_attacks.has(event.card): return
	if event.who.metadata.type != Genesis.CardType.SUPPORT:
		event.has_failed = true
		return
	
	var burrower : ICardInstance = event.card
	burrowers_to_attacks[burrower] += 1
	if burrowers_to_attacks[burrower] >= 3:
		game_access.epsm.unregister_event_processing_steps_by_requester_and_target(self, burrower)
		burrowers_to_attacks.erase(burrower)
