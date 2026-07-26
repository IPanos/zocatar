extends Node

class_name GameState

const ORIGINS: Array[String] = ["Aether", "Tide", "Terra", "Pyre"]

# Elemental opposite pairs — used by ScalingEngine to assign the final boss origin.
const OPPOSITE_ORIGIN: Dictionary = {
	"Aether": "Terra",
	"Terra": "Aether",
	"Tide": "Pyre",
	"Pyre": "Tide",
}

var starting_origin: String = ""
var unlocked_seals: Array[String] = []
var unlocked_disciplines: Array[String] = []
var equipped_move_deck: Array[String] = []
var world_flags: Dictionary = {}

signal origin_changed(new_origin: String)
signal seal_unlocked(seal_name: String)
signal discipline_unlocked(discipline_name: String)
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

func unlock_discipline(discipline_name: String) -> void:
	if discipline_name not in unlocked_disciplines:
		unlocked_disciplines.append(discipline_name)
		discipline_unlocked.emit(discipline_name)

func set_equipped_moves(moves: Array[String]) -> void:
	equipped_move_deck = moves

func set_world_flag(flag_name: String, value: bool) -> void:
	world_flags[flag_name] = value
	world_flag_changed.emit(flag_name, value)

func get_world_flag(flag_name: String, default: bool = false) -> bool:
	return world_flags.get(flag_name, default)

func get_zone_level() -> int:
	return unlocked_seals.size()
