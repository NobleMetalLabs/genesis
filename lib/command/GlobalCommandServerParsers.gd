class_name GlobalCommandServerParsers
extends RefCounted

static func register_global_parsers() -> void:
	CommandServer.register_parser("int", parse_int)
	CommandServer.register_parser("float", parse_float)
	CommandServer.register_parser("bool", parse_bool)
	CommandServer.register_parser("statistic", parse_statistic)
	return

static func parse_int(value : String) -> int:
	return int(value)

static func parse_float(value : String) -> float:
	return float(value)

static func parse_bool(value : String) -> bool:
	return value.to_lower() == "true"

static func parse_statistic(value : String) -> Genesis.Statistic:
	return Genesis.Statistic.keys().find(value) as Genesis.Statistic
