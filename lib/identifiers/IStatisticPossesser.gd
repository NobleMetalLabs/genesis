class_name IStatisticPossessor
extends Identifier
## 統計情報を持つクラスのインターフェース

static func id(node : Node) -> IStatisticPossessor:
	if node is Identifier:
		node = node.get_object()
	if node == null: return null
	if not node.has_node("IStatisticPossessor"): return null
	return node.get_node("IStatisticPossessor")

var _statistic_db : Dictionary

func _init() -> void:
	self.name = "IStatisticPossessor"
	_statistic_db = {}
	

func clone() -> IStatisticPossessor:
	return IStatisticPossessor.new().copy(self)

func get_statistic(statistic_name : Genesis.Statistic) -> Variant:
	var value : Variant = null
	
	if _statistic_db.has(statistic_name):
		value = _statistic_db.get(statistic_name)
	else:
		if Genesis.STATISTIC_DEFAULTS.has(statistic_name):
			value = Genesis.STATISTIC_DEFAULTS.get(statistic_name)
		else:
			push_warning("No default value for %s" % [Genesis.Statistic.keys()[statistic_name]])

	var mp_sibling := IMoodPossessor.id(self)
	if mp_sibling != null:
		return mp_sibling._get_statistic(statistic_name, value)
	return value

func set_statistic(statistic : Genesis.Statistic, value : Variant) -> void:
	_statistic_db[statistic] = value

func modify_statistic(statistic_name : Genesis.Statistic, value : Variant) -> void:
	var current_value : Variant = get_statistic(statistic_name)
	var new_value : Variant = current_value + value
	set_statistic(statistic_name, new_value)
