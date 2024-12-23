class_name CardBackend
extends Node

func _init(ci : ICardInstance) -> void:
	self.add_child(ci)
	var stats := IStatisticPossessor.new()
	self.add_child(stats)
	reset_stats()
	self.add_child(IMoodPossessor.new())

	self.name = self._to_string()

func _to_string() -> String:
	return "CardBackend<%s>" % ICardInstance.id(self)

func reset_stats() -> void:
	var stats := IStatisticPossessor.id(self)
	stats.set_statistic(Genesis.Statistic.HEALTH, ICardInstance.id(self).metadata.health)
	stats.set_statistic(Genesis.Statistic.STRENGTH, ICardInstance.id(self).metadata.strength)
	stats.set_statistic(Genesis.Statistic.SPEED, ICardInstance.id(self).metadata.speed)
	stats.set_statistic(Genesis.Statistic.ENERGY, ICardInstance.id(self).metadata.energy)
	
	for statistic : Genesis.Statistic in Genesis.STATISTIC_DEFAULTS.keys():
		var default_value : Variant = Genesis.STATISTIC_DEFAULTS[statistic]
		if default_value is Array or default_value is Dictionary:
			stats.set_statistic(statistic, default_value.duplicate())
