class_name Cooldown
extends RefCounted

var game_access : GameAccess
var subject : Object
var type : Genesis.CooldownType
var repeating : bool
var remaining_ticks : int = 0
var total_ticks : int = 0

signal cooldown_finished()
signal coolup_finished()

func _init(_game_access : GameAccess, _subject : Object, _type : Genesis.CooldownType, _repeating : bool, _remaining_ticks : int, _total_ticks : int = -1) -> void:
	self.game_access = _game_access
	self.subject = _subject
	self.type = _type
	self.repeating = _repeating
	self.remaining_ticks = _remaining_ticks
	if _total_ticks < 0: self.total_ticks = _remaining_ticks
	else: self.total_ticks = _total_ticks
	
	game_access.epsm._register_bulk([
		EventProcessingStep.new(
			NoTargetGroup.new(), "PROCESS_AUTOMATED", self, func HANDLE_AUTO_DECREMENT(_pae : ProcessAutomatedEvent): decrement(),
				EventPriority.new().STAGE(EventPriority.PROCESSING_STAGE.EVENT).INDIVIDUAL(EventPriority.PROCESSING_INDIVIDUAL_MIN)
		)
	])

func decrement(amount : int = 1) -> void:
	self.remaining_ticks -= amount
	if self.remaining_ticks <= 0:
		self.remaining_ticks = 0
		cooldown_finished.emit()

func increment(amount : int = 1) -> void:
	self.remaining_ticks += amount
	if self.remaining_ticks >= self.total_ticks:
		self.remaining_ticks = self.total_ticks
		coolup_finished.emit()

func restart() -> void:
	self.remaining_ticks = self.total_ticks

func _teardown() -> void:
	game_access.epsm.unregister_event_processing_steps_by_requester(self)
	#free()

func _to_string() -> String:
	return "Cooldown(%s,%s,%s/%s)" % [self.subject, Genesis.CooldownType.keys()[self.type], self.remaining_ticks, self.total_ticks]
