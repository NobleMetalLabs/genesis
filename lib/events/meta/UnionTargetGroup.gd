class_name UnionTargetGroup
extends BaseTargetGroup

var groups : Array[BaseTargetGroup]

func _init(_groups : Array[BaseTargetGroup]) -> void:
	groups = _groups

func does_group_contain(target : Object) -> bool:
	for group in groups:
		if group.does_group_contain(target):
			return true
	return false

func _to_string() -> String:
	var group_strings : Array[String] = []
	for group in groups:
		group_strings.append(group._to_string())
	return "UnionTargetGroup[%s]" % group_strings
