class_name EventHistory
extends RefCounted

var _events_by_gametick : Dictionary = {} # [int, Array[Event]]
var _events_by_card : Dictionary = {} # [ICardInstance, Array[Event]]
var _event_processing_records : Dictionary = {} # [Event, EventProcessingRecord]

func _init() -> void:
	set_current_gametick(0)

func _to_string() -> String:
	return "EventHistory(%s)" % [hash(self)]

func get_events_at_gametick(gametick : int) -> Array[Event]:
	var gametick_events : Array[Event] = []
	gametick_events.assign(_events_by_gametick.get(gametick, gametick_events))
	return gametick_events

func get_events_by_card(card : ICardInstance) -> Array[Event]:
	var card_events : Array[Event] = []
	card_events.assign(_events_by_card.get(card, card_events))
	return card_events

func get_most_recent_event_of_type_by_card(card : ICardInstance, event_type : StringName) -> Event:
	var card_events : Array[Event] = get_events_by_card(card).duplicate()
	while not card_events.is_empty():
		var event : Event = card_events.pop_back()
		if event.event_type == event_type: return event
	
	return null

func get_event_processing_record(event : Event) -> EventProcessingRecord:
	return _event_processing_records.get(event)

var _current_gametick : int = 0
func set_current_gametick(gametick : int) -> void:
	if gametick < _current_gametick:
		var stale_ticks : Array = _events_by_gametick.keys().filter(func(tick: int) -> bool: return tick > gametick)
		for tick : int in stale_ticks:
			for event : Event in _events_by_gametick[tick]:
				_event_processing_records.erase(event)
			_events_by_gametick.erase(tick)
	
	_current_gametick = gametick

var _processing_events_stack : Array[Event] = []
func _signal_begin_processing_event(event : Event) -> void:
	var causer_event : Event = null
	if _current_processing_step_stack.size() > 0:
		causer_event = _processing_events_stack.back()
		_event_processing_records[causer_event].add_caused_event(event, _current_processing_step_stack.back())
	_event_processing_records[event] = EventProcessingRecord.new(0, event, causer_event)
	var involved_cards : Array[ICardInstance] = []
	involved_cards.assign(Event.get_event_property_names_of_cards(event).map(
		func get_card_from_event(property_name : StringName) -> ICardInstance:
			return event.get(property_name)
	))
	for card : ICardInstance in involved_cards:
		if card == null: continue
		var card_events : Array[Event] = [] 
		_events_by_card.get_or_add(card, card_events).append(event)
	_processing_events_stack.append(event)
	pass

var _current_processing_step_stack : Array[EventProcessingStep] = []
func _signal_begin_processing_step(processing_step : EventProcessingStep) -> void:
	_event_processing_records[_processing_events_stack.back()].add_processing_step(processing_step)
	_current_processing_step_stack.append(processing_step)

func _signal_end_processing_step() -> void:
	_current_processing_step_stack.pop_back()

func _signal_end_processing_event() -> void:
	var event : Event = _processing_events_stack.pop_back()
	var gametick_events : Array[Event] = []
	if _event_processing_records[event].processing_steps.is_empty():
		_event_processing_records.erase(event)
	else:
		_events_by_gametick.get_or_add(_current_gametick, gametick_events).append(event)
	
	

class EventProcessingRecord extends RefCounted:
	var gametick : int
	var event : Event
	var processing_steps : Array[EventProcessingStep]
	var caused_by_event : Event
	var caused_events : Array[Event]
	var caused_events_by_processing_step : Dictionary

	func _init(_gametick : int, _event : Event, _caused_by : Event) -> void:
		gametick = _gametick
		event = _event
		caused_by_event = _caused_by
		processing_steps = []
		caused_events = []
		caused_events_by_processing_step = {}

	func add_processing_step(processing_step : EventProcessingStep) -> void:
		processing_steps.append(processing_step)
		var empty : Array[Event] = []
		caused_events_by_processing_step[processing_step] = empty

	func add_caused_event(caused_event : Event, processing_step : EventProcessingStep) -> void:
		caused_events.append(caused_event)
		caused_events_by_processing_step[processing_step].append(caused_event)
