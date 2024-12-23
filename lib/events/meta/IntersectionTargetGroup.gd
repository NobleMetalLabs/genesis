class_name IntersectionTargetGroup
extends BaseTargetGroup

var groups : Array[BaseTargetGroup]

func _init(_groups : Array[BaseTargetGroup]) -> void:
	groups = _groups

func does_group_contain(target : Object) -> bool:
	for group in groups:
		if not group.does_group_contain(target):
			return false
	return true

func _to_string() -> String:
	var group_strings : Array[String] = []
	for group in groups:
		group_strings.append(group._to_string())
	return "IntersectionTargetGroup[%s]" % group_strings
