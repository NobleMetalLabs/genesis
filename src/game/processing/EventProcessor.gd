class_name EventProcessor
extends RefCounted

var _event_processing_step_manager : EventProcessingStepManager
var _event_history : EventHistory
func _init(event_processing_step_manager : EventProcessingStepManager, event_history : EventHistory) -> void:
	_event_processing_step_manager = event_processing_step_manager
	_event_history = event_history

var requested_events : Array[Event] = []
func request_event(_event : Event) -> void:
	if _event == null: return
	if currently_processing_events:
		process_event(_event, current_delta_recorder)
	else:
		requested_events.append(_event)

var currently_processing_events : bool = false
var current_delta_recorder : GameAccessDeltaRecorder
func process_events(delta_recorder : GameAccessDeltaRecorder) -> void:
	currently_processing_events = true
	current_delta_recorder = delta_recorder
	for event : Event in requested_events:
		process_event(event, current_delta_recorder)
	requested_events.clear()
	currently_processing_events = false

func process_event(event : Event, delta_recorder : GameAccessDeltaRecorder) -> void:
	_event_processing_step_manager.process_event(event, _event_history, delta_recorder)

func _to_string() -> String: return "EP(%s, %s)" % [hash(self), _event_processing_step_manager]
