class_name Sandbox
extends RefCounted

var game_access_manager := GameAccessManager.new()
var game_access : GameAccess = game_access_manager.game_access

func _init() -> void:
	game_access.event_processor = game_access_manager.event_processor
	DefaultCardLogic.new(game_access).register_base_processing_steps()
	game_access.event_processing_step_manager.register_event_processing_step(
		EventProcessingStep.new(AllCardsTargetGroup.new(), "CREATED", self, BUILD_CARD, EventPriority.new().INDIVIDUAL(EventPriority.PROCESSING_INDIVIDUAL_MIN + 1))
	)
	
	register_commands()

func _teardown() -> void:
	for player : Player in players.values(): player.free()

func _to_string() -> String: return "SANDBOX"

func BUILD_CARD(event : CreatedEvent) -> void:
	var new_card : ICardInstance = spawn_card(event.what, players.find_key(event.card.player))
	event._resultant_card = new_card

func _handle_spawn(id : int, player_num : int) -> void:
	var new_card : ICardInstance = spawn_card(CardDB.get_card_by_id(id), player_num)
	game_access.request_event(WasCreatedEvent.new(new_card))

var players : Dictionary = {} #[int, Player]
func spawn_card(metadata : CardMetadata, player_num : int) -> ICardInstance:
	var player : Player = players.get(player_num)
	if player == null:
		player = _new_player(player_num)
	var component := ICardInstance.new(metadata, player, game_access)
	component.logic._register_processing_steps()
	component.logic.verbose = true
	var new_ent := CardBackend.new(component)
	UIDDB.register_object(new_ent, UIDDB.uid_to_object.size() + 1)
	return component

func _new_player(num : int) -> Player:
	var player : Player = Player.setup(Deck.EMPTY)
	player.name = "P%d" % [num]
	players[num] = player
	game_access.add_player(player)
	return player

func issue_simple_event_to_card(uid : int, event_type : StringName) -> void:
	var ent := UIDDB.object(uid)
	var card := ICardInstance.id(ent)
	var event : Event
	match event_type:
		"entered-deck-event": event = EnteredDeckEvent.new(card)
		"entered-field-event": event = EnteredFieldEvent.new(card)
		"entered-hand-event": event = EnteredHandEvent.new(card)
		"was-activated-event": event = WasActivatedEvent.new(card)
		"was-burned-event": event = WasBurnedEvent.new(card)
		"was-created-event": event = WasCreatedEvent.new(card)
		"was-discarded-event": event = WasDiscardedEvent.new(card)
		"was-marked-event": event = WasMarkedEvent.new(card)
		"was-unmarked-event": event = WasUnmarkedEvent.new(card)
		_: push_error("Unknown event type: %s" % [event_type])
	game_access.request_event(event)

func _get_uiddb_uids() -> Array[StringName]:
	var output : Array[StringName] = []
	output.assign(UIDDB.uid_to_object.keys().map(func to_sn(uid : int) -> StringName: return str(uid)))
	return output

func _get_player_ids() -> Array[StringName]:
	var output : Array[StringName] = []
	output.assign(players.keys().map(func to_sn(uid : int) -> StringName: return str(uid)))
	return output

# func is_uid_of_existing_card(value : String) -> bool:
# 	if not value.is_valid_int(): return false
# 	var uid := value.to_int()
# 	if not UIDDB.has_uid(uid): return false
# 	var obj := UIDDB.object(uid)
# 	var ci := ICardInstance.id(obj)
# 	return ci != null

func register_commands() -> void:
	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("card").Literal("spawn")
			.Key("name", CardDB.get_card_names)
				.Tag("card-id", "int", CardDB.get_id_by_name)
			.Validated("player-num", GlobalCommandValidators.is_valid_int_positive)
				.Tag_gn("int")
			.Callback(_handle_spawn, ["card-id", "player-num"])
		.Build()
	)

	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("card").Literal("act")
			.Key("uid", _get_uiddb_uids)
				.Tag_gn("int")
			.Literal("event")
			.Branch()
				.Literal("attacked-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Validated("damage", GlobalCommandValidators.is_valid_int_positive)
					.Tag_gn("int")
				.Callback(
					func issue_attack(uid : int, target_uid : int, damage : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := AttackedEvent.new(card, target, damage)
						game_access.request_event(event)
						, ["uid", "target_uid", "damage"]
				)
			.NextBranch()
				.Literal("was-attacked-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Validated("damage", GlobalCommandValidators.is_valid_int_positive)
					.Tag_gn("int")
				.Callback(
					func issue_was_attacked(uid : int, target_uid : int, damage : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := WasAttackedEvent.new(card, target, damage)
						game_access.request_event(event)
						, ["uid", "target_uid", "damage"]
				)
			.NextBranch()
				.Literal("killed-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag("target_uid", "int")
				.Callback(
					func issue_kill(uid : int, target_uid : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := KilledEvent.new(card, target)
						game_access.request_event(event)
						, ["uid", "target_uid"]
				)
			.NextBranch()
				.Literal("was-killed-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag("target_uid", "int")
				.Callback(
					func issue_was_killed(uid : int, target_uid : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := WasKilledEvent.new(card, target)
						game_access.request_event(event)
						, ["uid", "target_uid"]
				)
			.NextBranch()
				.Literal("supported-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag("target_uid", "int")
				.Callback(
					func issue_support(uid : int, target_uid : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := SupportedEvent.new(card, target)
						game_access.request_event(event)
						, ["uid", "target_uid"]
				)
			.NextBranch()
				.Literal("was-supported-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag("target_uid", "int")
				.Callback(
					func issue_was_supported(uid : int, target_uid : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := WasSupportedEvent.new(card, target)
						game_access.request_event(event)
						, ["uid", "target_uid"]
				)
			.NextBranch()
				.Literal("targeted-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag("target_uid", "int")
				.Callback(
					func issue_target(uid : int, target_uid : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := TargetedEvent.new(card, target)
						game_access.request_event(event)
						, ["uid", "target_uid"]
				)
			.NextBranch()
				.Literal("was-targeted-event")
				.Key("target_uid", _get_uiddb_uids)
					.Tag("target_uid", "int")
				.Callback(
					func issue_support(uid : int, target_uid : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var target := ICardInstance.id(UIDDB.object(target_uid)) 
						var event := WasSupportedEvent.new(card, target)
						game_access.request_event(event)
						, ["uid", "target_uid"]
				)
			.NextBranch()
				.Literal("created-event")
				.Key("name", CardDB.get_card_names)
					.Tag("card_id", "int", CardDB.get_id_by_name)
				.Callback(
					func issue_create(uid : int, card_id : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						var event := CreatedEvent.new(card, CardDB.get_card_by_id(card_id))
						game_access.request_event(event)
						, ["uid", "card_id"]
				)
		.Build()
	)

	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("card").Literal("act")
			.Key("uid", _get_uiddb_uids)
				.Tag_gn("int")
			.Literal("event")
			.Branch()
				.Literal("gave-mood-event")
				.Key("who_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Branch()
					.Literal("summoning")
					.Callback(
						func issue_gave_summoning_mood(uid : int, who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var who := ICardInstance.id(UIDDB.object(who_uid))
							game_access.request_event(GaveMoodEvent.new(card, who, SummoningMood.new(card)))
							, ["uid", "who_uid"]
					)
				.NextBranch()
					.Literal("boredom")
					.Callback(
						func issue_gave_boredom_mood(uid : int, who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var who := ICardInstance.id(UIDDB.object(who_uid))
							game_access.request_event(GaveMoodEvent.new(card, who, BoredomMood.new(card)))
							, ["uid", "who_uid"]
					)
				.NextBranch()
					.Key("mood-type", StatisticMood.get.bind("MOOD_NAMES"))
						.Tag_gnst()
					.Validated("amount", GlobalCommandValidators.is_valid_int_positive)
						.Tag_gn("int")
					.Callback(
						func issue_gave_statistic_mood(uid : int, who_uid : int, mood_type : StringName, amount : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var who := ICardInstance.id(UIDDB.object(who_uid))
							var mood := StatisticMood.FROM_NAME(card, mood_type, amount)
							game_access.request_event(GaveMoodEvent.new(card, who, mood))
							, ["uid", "who_uid", "mood-type", "amount"]
					)
				.EndBranch()
			.NextBranch()
				.Literal("gained-mood-event")
				.Key("from_who_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Branch()
					.Literal("summoning")
					.Callback(
						func issue_gave_summoning_mood(uid : int, from_who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var from_who := ICardInstance.id(UIDDB.object(from_who_uid))
							game_access.request_event(GainedMoodEvent.new(card, from_who, SummoningMood.new(card)))
							, ["uid", "from_who_uid"]
					)
				.NextBranch()
					.Literal("boredom")
					.Callback(
						func issue_gave_boredom_mood(uid : int, from_who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var from_who := ICardInstance.id(UIDDB.object(from_who_uid))
							game_access.request_event(GainedMoodEvent.new(card, from_who, BoredomMood.new(card)))
							, ["uid", "from_who_uid"]
					)
				.NextBranch()
					.Key("mood-type", StatisticMood.get.bind("MOOD_NAMES"))
						.Tag_gnst()
					.Validated("amount", GlobalCommandValidators.is_valid_int_positive)
						.Tag_gn("int")
					.Callback(
						func issue_gave_statistic_mood(uid : int, from_who_uid : int, mood_type : StringName, amount : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var from_who := ICardInstance.id(UIDDB.object(from_who_uid))
							var mood := StatisticMood.FROM_NAME(card, mood_type, amount)
							game_access.request_event(GainedMoodEvent.new(card, from_who, mood))
							, ["uid", "from_who_uid", "mood-type", "amount"]
					)
				.EndBranch()
			.NextBranch()
				.Literal("took-mood-event")
				.Key("from_who_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Branch()
					.Literal("summoning")
					.Callback(
						func issue_gave_summoning_mood(uid : int, from_who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var from_who := ICardInstance.id(UIDDB.object(from_who_uid))
							game_access.request_event(TookMoodEvent.new(card, from_who, SummoningMood.new(card)))
							, ["uid", "from_who_uid"]
					)
				.NextBranch()
					.Literal("boredom")
					.Callback(
						func issue_gave_boredom_mood(uid : int, from_who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var from_who := ICardInstance.id(UIDDB.object(from_who_uid))
							game_access.request_event(TookMoodEvent.new(card, from_who, BoredomMood.new(card)))
							, ["uid", "from_who_uid"]
					)
				.NextBranch()
					.Key("mood-type", StatisticMood.get.bind("MOOD_NAMES"))
						.Tag_gnst()
					.Validated("amount", GlobalCommandValidators.is_valid_int_positive)
						.Tag_gn("int")
					.Callback(
						func issue_gave_statistic_mood(uid : int, from_who_uid : int, mood_type : StringName, amount : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var from_who := ICardInstance.id(UIDDB.object(from_who_uid))
							var mood := StatisticMood.FROM_NAME(card, mood_type, amount)
							game_access.request_event(TookMoodEvent.new(card, from_who, mood))
							, ["uid", "from_who_uid", "mood-type", "amount"]
					)
			.NextBranch()
				.Literal("lost-mood-event")
				.Key("by_who_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Branch()
					.Literal("summoning")
					.Callback(
						func issue_gave_summoning_mood(uid : int, by_who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var by_who := ICardInstance.id(UIDDB.object(by_who_uid))
							game_access.request_event(GainedMoodEvent.new(card, by_who, SummoningMood.new(card)))
							, ["uid", "by_who_uid"]
					)
				.NextBranch()
					.Literal("boredom")
					.Callback(
						func issue_gave_boredom_mood(uid : int, by_who_uid : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var by_who := ICardInstance.id(UIDDB.object(by_who_uid))
							game_access.request_event(GainedMoodEvent.new(card, by_who, BoredomMood.new(card)))
							, ["uid", "by_who_uid"]
					)
				.NextBranch()
					.Key("mood-type", StatisticMood.get.bind("MOOD_NAMES"))
						.Tag_gnst()
					.Validated("amount", GlobalCommandValidators.is_valid_int_positive)
						.Tag_gn("int")
					.Callback(
						func issue_gave_statistic_mood(uid : int, by_who_uid : int, mood_type : StringName, amount : int) -> void:
							var card := ICardInstance.id(UIDDB.object(uid))
							var by_who := ICardInstance.id(UIDDB.object(by_who_uid))
							var mood := StatisticMood.FROM_NAME(card, mood_type, amount)
							game_access.request_event(GainedMoodEvent.new(card, by_who, mood))
							, ["uid", "by_who_uid", "mood-type", "amount"]
					)
		.Build()
	)

	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("card").Literal("act")
			.Key("uid", _get_uiddb_uids)
				.Tag_gn("int")
			.Literal("event")
			.Branch().Literal("left-deck-event")
				.Key("reason", func get_deckreason_keys() -> Array[StringName]: 
					var keys : Array[StringName] = []
					keys.assign(Genesis.LeaveDeckReason.keys())
					return keys
					).Tag("reason_id", "int", func map_deckreason(value : String) -> int: 
						return Genesis.LeaveDeckReason.keys().find(value))
				.Callback(
					func issue_left_deck(uid : int, reason_id : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						game_access.request_event(LeftDeckEvent.new(card, reason_id as Genesis.LeaveDeckReason))
						, ["uid", "reason_id"]
				)
			.NextBranch().Literal("left-field-event")
				.Key("reason", func get_fieldreason_keys() -> Array[StringName]: 
					var keys : Array[StringName] = []
					keys.assign(Genesis.LeavePlayReason.keys())
					return keys
					).Tag("reason_id", "int", func map_fieldreason(value : String) -> int: 
						return Genesis.LeavePlayReason.keys().find(value))
				.Callback(
					func issue_left_field(uid : int, reason_id : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						game_access.request_event(LeftFieldEvent.new(card, reason_id as Genesis.LeavePlayReason))
						, ["uid", "reason_id"]
				)
			.NextBranch().Literal("left-hand-event")
				.Key("reason", func get_handreason_keys() -> Array[StringName]: 
					var keys : Array[StringName] = []
					keys.assign(Genesis.LeaveHandReason.keys())
					return keys
					).Tag("reason_id", "int", func map_handreason(value : String) -> int: 
						return Genesis.LeaveHandReason.keys().find(value))
				.Callback(
					func issue_left_hand(uid : int, reason_id : int) -> void:
						var card := ICardInstance.id(UIDDB.object(uid))
						game_access.request_event(LeftHandEvent.new(card, reason_id as Genesis.LeaveHandReason))
						, ["uid", "reason_id"]
				)
			.EndBranch()
		.Build()
	)
	
	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("card").Literal("act")
			.Key("uid", _get_uiddb_uids)
				.Tag_gn("int")
			.Literal("event").Literal("set-statistic-event")
			.Key("statistic", func get_statistics() -> Array[StringName]:
				var keys : Array[StringName] = []
				keys.assign(Genesis.Statistic.keys())
				return keys
				).Tag_gn("statistic")
			.Branch()
				.Condition(
					func is_statistic_bool_type(statistic: Genesis.Statistic) -> bool:
						return Genesis.STATISTIC_DEFAULTS[statistic] is bool,
					["statistic"]
				).Validated("value", GlobalCommandValidators.is_valid_bool).Tag_gn("bool")
			.NextBranch()
				.Condition(
					func is_statistic_int_type(statistic: Genesis.Statistic) -> bool:
						return Genesis.STATISTIC_DEFAULTS[statistic] is int,
					["statistic"]
				).Validated("value", GlobalCommandValidators.is_valid_int).Tag_gn("int")
			.EndBranch().Callback(
				func issue_set_statistic(uid : int, statistic : Genesis.Statistic, value : Variant) -> void:
					var card := ICardInstance.id(UIDDB.object(uid))
					game_access.request_event(SetStatisticEvent.new(card, statistic, value))
					, ["uid", "statistic", "value"]
				)
		.Build()
	)
	
	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("card").Literal("act")
			.Key("uid", _get_uiddb_uids)
				.Tag_gn("int")
			.Literal("event")
			.Branch().Literal("entered-deck-event")
			.NextBranch().Literal("entered-field-event")
			.NextBranch().Literal("entered-hand-event")
			.NextBranch().Literal("was-activated-event")
			.NextBranch().Literal("was-burned-event")
			.NextBranch().Literal("was-created-event")
			.NextBranch().Literal("was-discarded-event")
			.NextBranch().Literal("was-marked-event")
			.NextBranch().Literal("was-unmarked-event")
			.EndBranch().Tag_st("event-type")
			.Callback(issue_simple_event_to_card, ["uid", "event-type"])
		.Build()
	)
	
	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("player").Literal("act")
			.Key("player_id", _get_player_ids)
				.Tag_gn("int")
			.Literal("event")
			.Branch()
				.Literal("burned-hand-event")
				.Callback(
					func issue_burn_hand(player_id : int) -> void:
						var player : Player = players[player_id]
						game_access.request_event(BurnedHandEvent.new(player))
						, ["player_id"]
				)
			.NextBranch()
				.Literal("began-deck-maintenance-event")
				.Callback(
					func issue_began_dm(player_id : int) -> void:
						var player : Player = players[player_id]
						game_access.request_event(BeganDeckMaintenanceEvent.new(player))
						, ["player_id"]
				)
			.NextBranch()
				.Literal("ended-deck-maintenance-event")
				.Callback(
					func issue_ended_dm(player_id : int) -> void:
						var player : Player = players[player_id]
						game_access.request_event(EndedDeckMaintenanceEvent.new(player))
						, ["player_id"]
				)
			.NextBranch()
				.Literal("played-card-event")
				.Key("card_uid", _get_uiddb_uids)
					.Tag_gn("int")
				.Callback(
					func issue_played_card(player_id : int, card_uid : int) -> void:
						var player : Player = players[player_id]
						var card := ICardInstance.id(UIDDB.object(card_uid))
						game_access.request_event(PlayedCardEvent.new(player, card))
						, ["player_id", "card_uid"]
				)
		.Build()
	)
