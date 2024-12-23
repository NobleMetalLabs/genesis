class_name DefaultCardLogic
extends CardLogic
# TODO: this probably shouldnt be a cardlogic, all its getting from super is gameaccess

func _init(_game_access : GameAccess) -> void:
	super(null, _game_access)

func _to_string() -> String:
	return "DEFAULT-LOGIC"

func register_base_processing_steps() -> void:
	var tg := AllCardsTargetGroup.new()
	var pr := EventPriority.new().INDIVIDUAL(EventPriority.PROCESSING_INDIVIDUAL_MIN)
	game_access.event_processing_step_manager._register_bulk([
		EventProcessingStep.new(tg, "ENTERED_DECK", self, _handle_entered_deck, pr),
		EventProcessingStep.new(tg, "LEFT_DECK", self, _handle_left_deck, pr),
		EventProcessingStep.new(tg, "ENTERED_HAND", self, _handle_entered_hand, pr),
		EventProcessingStep.new(tg, "LEFT_HAND", self, _handle_left_hand, pr),
		EventProcessingStep.new(tg, "ENTERED_FIELD", self, _handle_entered_field, pr),
		EventProcessingStep.new(tg, "LEFT_FIELD", self, _handle_left_field, pr),
		EventProcessingStep.new(tg, "WAS_BURNED", self, _handle_was_burned, pr),
		EventProcessingStep.new(tg, "WAS_MARKED", self, _handle_was_marked, pr),
		EventProcessingStep.new(tg, "WAS_UNMARKED", self, _handle_was_unmarked, pr),
		EventProcessingStep.new(tg, "WAS_DISCARDED", self, _handle_was_discarded, pr),
		EventProcessingStep.new(tg, "CREATED", self, _handle_created, pr),	
		EventProcessingStep.new(tg, "WAS_CREATED", self, _handle_was_created, pr),
		EventProcessingStep.new(tg, "ATTACKED", self, _handle_attacked, pr),
		EventProcessingStep.new(tg, "WAS_ATTACKED", self, _handle_was_attacked, pr),
		EventProcessingStep.new(tg, "WAS_ACTIVATED", self, _handle_was_activated, pr),
		EventProcessingStep.new(tg, "TARGETED", self, _handle_targeted, pr),
		EventProcessingStep.new(tg, "WAS_TARGETED", self, _handle_was_targeted, pr),
		EventProcessingStep.new(tg, "SUPPORTED", self, _handle_supported, pr),
		EventProcessingStep.new(tg, "WAS_SUPPORTED", self, _handle_was_supported, pr),
		EventProcessingStep.new(tg, "KILLED", self, _handle_killed, pr),
		EventProcessingStep.new(tg, "WAS_KILLED", self, _handle_was_killed, pr),
		EventProcessingStep.new(tg, "GAVE_MOOD", self, _handle_gave_mood, pr),
		EventProcessingStep.new(tg, "GAINED_MOOD", self, _handle_gained_mood, pr),
		EventProcessingStep.new(tg, "TOOK_MOOD", self, _handle_took_mood, pr),
		EventProcessingStep.new(tg, "LOST_MOOD", self, _handle_lost_mood, pr),
		EventProcessingStep.new(tg, "SET_STATISTIC", self, _handle_set_statistic, pr),
		EventProcessingStep.new(tg, "SET_COOLDOWN", self, _handle_set_cooldown, pr),
	])


func _handle_entered_deck(event : EnteredDeckEvent) -> void:
	if verbose: print("%s entered deck of %s" % [event.card, event.card.player])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_IN_DECK, true)
	return

func _handle_left_deck(event : LeftDeckEvent) -> void:
	if verbose: print("%s left deck of %s" % [event.card, event.card.player])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_IN_DECK, false)
	return

func _handle_entered_hand(event : EnteredHandEvent) -> void:
	if verbose: print("%s entered hand of %s" % [event.card, event.card.player])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_IN_HAND, true)
	return

func _handle_left_hand(event : LeftHandEvent) -> void:
	if verbose: print("%s left hand of %s" % [event.card, event.card.player])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_IN_HAND, false)
	return

func _handle_entered_field(event : EnteredFieldEvent) -> void:
	if verbose: print("%s entered field of %s" % [event.card, event.card.player])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_ON_FIELD, true)
	
	var ssickness_cooldown := Cooldown.new(game_access, event.card, Genesis.CooldownType.SSICKNESS, false, 100)
	ssickness_cooldown.cooldown_finished.connect(ssickness_cooldown._teardown)
	
	game_access.request_event(SetCooldownEvent.new(event.card, ssickness_cooldown))
	return

func _handle_left_field(event : LeftFieldEvent) -> void:
	if verbose: print("%s left field of %s" % [event.card, event.card.player])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_ON_FIELD, false)
	return

func _handle_was_burned(event : WasBurnedEvent) -> void:
	if verbose: print("%s was burned" % [event.card])
	game_access.request_event(LeftHandEvent.new(event.card))
	return

func _handle_was_marked(event : WasMarkedEvent) -> void:
	if verbose: print("%s was marked" % [event.card])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_MARKED, true)
	return

func _handle_was_unmarked(event : WasUnmarkedEvent) -> void:
	if verbose: print("%s was unmarked" % [event.card])
	IStatisticPossessor.id(event.card).set_statistic(Genesis.Statistic.IS_MARKED, false)
	return

func _handle_was_discarded(event : WasDiscardedEvent) -> void:
	if verbose: print("%s was discarded" % [event.card])
	game_access.request_event(LeftHandEvent.new(event.card))
	return

func _handle_created(event : CreatedEvent) -> void:
	if verbose: print("%s created %s" % [event.card, event.what])
	game_access.request_event(WasCreatedEvent.new(event.get_resultant_card(), event.card))
	return

func _handle_was_created(event : WasCreatedEvent) -> void:
	if verbose: 
		if event.by != null:
			print("%s was created by %s" % [event.card, event.by])
		else:
			print("%s was created" % [event.card])
	return

func _handle_attacked(event : AttackedEvent) -> void:
	if verbose: print("%s attacked %s for %s" % [event.card, event.who, event.damage])
	game_access.request_event(WasAttackedEvent.new(event.who, event.card, event.damage))
	return

func _handle_was_attacked(event : WasAttackedEvent) -> void:
	if verbose: print("%s was attacked by %s for %s" % [event.card, event.by_who, event.damage])
	var health : int = IStatisticPossessor.id(event.card).get_statistic(Genesis.Statistic.HEALTH)
	var new_health : int = health - event.damage
	game_access.request_event(SetStatisticEvent.new(event.card, Genesis.Statistic.HEALTH, new_health))
	
	if new_health <= 0:
		game_access.request_event(KilledEvent.new(event.by_who, event.card))
	return

func _handle_was_activated(event : WasActivatedEvent) -> void:
	if verbose: print("%s was activated" % [event.card])
	# NOTE: code for cards that need charges to activate
	#if IStatisticPossessor.id(event.card).card_stats.get_statistic(Genesis.Statistic.CHARGES) <= 0: 
		#event.has_failed = true
		#return
	#
	#game_access.request_event(SetStatisticEvent.modify(event.card, Genesis.Statistic.CHARGES, -1))
	return

func _handle_targeted(event : TargetedEvent) -> void:
	if verbose: print("%s targeted %s" % [event.card, event.who])
	
	var card_stats := IStatisticPossessor.id(event.card)
	card_stats.set_statistic(Genesis.Statistic.HAS_TARGET, event.who != null)
	card_stats.set_statistic(Genesis.Statistic.TARGET, event.who)
	
	if event.who == null: return
	
	if event.card.metadata.type == Genesis.CardType.SUPPORT:
		if game_access.are_two_cards_friendly(event.card, event.who):
			game_access.request_event(SupportedEvent.new(event.card, event.who))
			return
	game_access.request_event(WasTargetedEvent.new(event.who, event.card))
	return

func _handle_was_targeted(event : WasTargetedEvent) -> void:
	if verbose: print("%s was targeted by %s" % [event.card, event.by])
	return

func _handle_supported(event : SupportedEvent) -> void:
	if verbose: print("%s supported %s" % [event.card, event.who])
	game_access.request_event(WasSupportedEvent.new(event.who, event.card))
	return

func _handle_was_supported(event : WasSupportedEvent) -> void:
	if verbose: print("%s was supported by %s" % [event.card, event.by])
	return

func _handle_killed(event : KilledEvent) -> void:
	if verbose: print("%s killed %s" % [event.card, event.who])
	game_access.request_event(WasKilledEvent.new(event.who, event.card))
	return

func _handle_was_killed(event : WasKilledEvent) -> void:
	if verbose: print("%s was killed by %s" % [event.card, event.by])
	var card_stats := IStatisticPossessor.id(event.card)
	
	if card_stats.get_statistic(Genesis.Statistic.IS_ON_FIELD):
		game_access.request_event(LeftFieldEvent.new(event.card))
	elif card_stats.get_statistic(Genesis.Statistic.IS_IN_HAND):
		game_access.request_event(LeftHandEvent.new(event.card))
	else:
		game_access.request_event(LeftDeckEvent.new(event.card))
	
	game_access.request_event(TargetedEvent.new(event.card, null))
	
	if card_stats.get_statistic(Genesis.Statistic.IS_TRANSIENT): return
	
	game_access.request_event(WasMarkedEvent.new(event.card))
	game_access.request_event(EnteredDeckEvent.new(event.card))
	
	return

func _handle_gave_mood(event : GaveMoodEvent) -> void:
	if verbose: print("%s gave %s mood %s" % [event.card, event.who, event.mood])
	game_access.request_event(GainedMoodEvent.new(event.who, event.card, event.mood))
	return

func _handle_gained_mood(event : GainedMoodEvent) -> void:
	if verbose: print("%s gained mood %s from %s" % [event.card, event.mood, event.from])
	IMoodPossessor.id(event.card).apply_mood(event.mood)
	return

func _handle_took_mood(event : TookMoodEvent) -> void:
	if verbose: print("%s took mood %s from %s" % [event.card, event.mood, event.who])
	game_access.request_event(LostMoodEvent.new(event.who, event.card, event.mood))
	return

func _handle_lost_mood(event : LostMoodEvent) -> void:
	if verbose: print("%s lost mood %s from %s" % [event.card, event.mood, event.by])
	IMoodPossessor.id(event.card).remove_mood(event.mood)
	return

func _handle_set_statistic(event : SetStatisticEvent) -> void:
	if verbose: print("set statistic placeholder")
	IStatisticPossessor.id(event.subject).set_statistic(event.statistic, event.new_value)
	return

func _handle_set_cooldown(event : SetCooldownEvent) -> void:
	if verbose: print("set cooldown placeholder")
	var subject_stats := IStatisticPossessor.id(event.subject)
	var current_cooldowns : Dictionary = subject_stats.get_statistic(Genesis.Statistic.CURRENT_COOLDOWNS)
	var existing_cooldown_with_same_type : Cooldown = current_cooldowns.get(event.cooldown.type, null)
	
	if existing_cooldown_with_same_type == null: current_cooldowns[event.cooldown.type] = event.cooldown
	elif event.override_or_combine: # override
		existing_cooldown_with_same_type.remaining_ticks = event.cooldown.remaining_ticks
		existing_cooldown_with_same_type.total_ticks = event.cooldown.total_ticks
	else: # combine
		existing_cooldown_with_same_type.remaining_ticks += event.cooldown.remaining_ticks
		existing_cooldown_with_same_type.total_ticks += event.cooldown.total_ticks
	return

# func _handle_played_card(event : PlayedCardEvent) -> void:
# 	if verbose: print("%s played card %s" % [event.card.player, event.card])
# 	game_access.request_event(LeftHandEvent.new(event.card))
# 	game_access.request_event(EnteredFieldEvent.new(event.card))
# 	return

# func _handle_burned_hand(event : BurnedHandEvent) -> void:
# 	if verbose: print("%s burned hand" % [event.card.player])
# 	return

# func _handle_began_deck_maintenance(event : BeganDeckMaintenanceEvent) -> void:
# 	if verbose: print("%s began deck maintenance" % [event.card.player])
# 	return

# func _handle_ended_deck_maintenance(event : EndedDeckMaintenanceEvent) -> void:
# 	if verbose: print("%s ended deck maintenance" % [event.card.player])
# 	return
