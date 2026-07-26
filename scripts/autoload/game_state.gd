extends Node

class_name GameState

var starting_origin: String = ""
var unlocked_seals: Array[String] = []
var equipped_move_deck: Array[String] = []
var world_flags: Dictionary = {}

signal origin_changed(new_origin: String)
signal seal_unlocked(seal_name: String)
signal world_flag_changed(flag_name: String, value: bool)

func _ready() -> void:
	name = "GameState"

func set_starting_origin(origin: String) -> void:
	starting_origin = origin
	origin_changed.emit(origin)

func unlock_seal(seal_name: String) -> void:
	if seal_name not in unlocked_seals:
		unlocked_seals.append(seal_name)
		seal_unlocked.emit(seal_name)

func set_equipped_moves(moves: Array[String]) -> void:
	equipped_move_deck = moves

func set_world_flag(flag_name: String, value: bool) -> void:
	world_flags[flag_name] = value
	world_flag_changed.emit(flag_name, value)

func get_world_flag(flag_name: String, default: bool = false) -> bool:
	return world_flags.get(flag_name, default)

func get_zone_level() -> int:
	return unlocked_seals.size()
