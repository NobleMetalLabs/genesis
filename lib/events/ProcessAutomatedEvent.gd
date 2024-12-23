class_name ProcessAutomatedEvent
extends Event

func _init() -> void:
	self.event_type = "PROCESS_AUTOMATED"

func _to_string() -> String:
	return "ProcessAutomatedEvent()"
