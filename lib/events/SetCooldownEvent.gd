class_name SetCooldownEvent
extends Event

var subject : Object
var cooldown : Cooldown
var override_or_combine : bool

func _init(_subject : Object, _cooldown : Cooldown, _override_or_combine : bool = true) -> void:
	self.event_type = "SET_COOLDOWN"
	self.subject = _subject
	
	self.cooldown = _cooldown
	self.override_or_combine = _override_or_combine

func _to_string() -> String:
	return "SetCooldownEvent(%s, %s, %s)" % [self.subject, self.cooldown, "Override" if override_or_combine else "Combine"]
