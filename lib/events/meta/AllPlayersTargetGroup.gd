class_name AllPlayersTargetGroup
extends BaseTargetGroup

func does_group_contain(target : Object) -> bool:
	if target is Player:
		return true
	return false

func _to_string() -> String:
	return "AllPlayersTargetGroup"
