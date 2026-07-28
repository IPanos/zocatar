extends Node

const ORIGINS: Array[String] = ["Aether", "Tide", "Terra", "Pyre"]

# Elemental opposite pairs — used by ScalingEngine to assign the final boss origin.
const OPPOSITE_ORIGIN: Dictionary = {
	"Aether": "Terra",
	"Terra": "Aether",
	"Tide": "Pyre",
	"Pyre": "Tide",
}

# Canonical seal id per origin — matches the "_seal" suffix convention used in quest_*.json prerequisites.
const ORIGIN_SEAL_IDS: Dictionary = {
	"Aether": "aether_seal",
	"Tide": "tide_seal",
	"Terra": "terra_seal",
	"Pyre": "pyre_seal",
}

# Sub-discipline unlocks from paired seals (Vitalis/Blood is excluded — it depends on tide_seal + a
# night-time condition, not a seal pair, and is granted directly via the sub_vitalis dialogue branch).
const SUB_DISCIPLINE_COMBOS: Dictionary = {
	"Lightning": ["pyre_seal", "aether_seal"],
	"Flora": ["tide_seal", "terra_seal"],
	"Vapor": ["aether_seal", "tide_seal"],
	"Metal": ["terra_seal", "pyre_seal"],
}

# Base moveset per origin: one plain attack, one signature status move. Covers all four
# canonical status conditions one-to-one (Aether/Stun, Tide/Freeze, Terra/Root, Pyre/Burn).
const STARTER_MOVES: Dictionary = {
	"Aether": ["move_gale_slash", "move_static_gust"],
	"Tide": ["move_tidal_press", "move_frost_lock"],
	"Terra": ["move_stone_fist", "move_root_wall"],
	"Pyre": ["move_ember_jab", "move_cinder_wave"],
}

const MAX_MOVE_DECK_SIZE: int = 6

var starting_origin: String = ""
var unlocked_seals: Array[String] = []
var unlocked_disciplines: Array[String] = []
var equipped_move_deck: Array[String] = []
var world_flags: Dictionary = {}

# Set by whoever handles DialogueManager.battle_triggered right before transitioning to
# the battle scene, so CombatantFactory can build an enemy appropriate to the encounter.
var pending_battle_encounter: String = ""

signal origin_changed(new_origin: String)
signal seal_unlocked(seal_name: String)
signal discipline_unlocked(discipline_name: String)
signal world_flag_changed(flag_name: String, value: bool)
signal move_deck_changed()

func _ready() -> void:
	name = "GameState"

func set_starting_origin(origin: String) -> void:
	starting_origin = origin
	if equipped_move_deck.is_empty():
		equipped_move_deck.assign(STARTER_MOVES.get(origin, []))
	origin_changed.emit(origin)

func unlock_seal(seal_name: String) -> void:
	if seal_name not in unlocked_seals:
		unlocked_seals.append(seal_name)
		seal_unlocked.emit(seal_name)
		_check_discipline_unlocks()

func has_seal(seal_id: String) -> bool:
	return seal_id in unlocked_seals

func _check_discipline_unlocks() -> void:
	for discipline_name in SUB_DISCIPLINE_COMBOS:
		if discipline_name in unlocked_disciplines:
			continue
		var required_seals: Array = SUB_DISCIPLINE_COMBOS[discipline_name]
		if required_seals.all(func(seal_id): return has_seal(seal_id)):
			unlock_discipline(discipline_name)

func unlock_discipline(discipline_name: String) -> void:
	if discipline_name not in unlocked_disciplines:
		unlocked_disciplines.append(discipline_name)
		discipline_unlocked.emit(discipline_name)

func set_equipped_moves(moves: Array[String]) -> void:
	equipped_move_deck = moves
	move_deck_changed.emit()

## Adds a newly-learned move to the deck if there's room and it isn't already equipped.
## A full deck at MAX_MOVE_DECK_SIZE is not auto-replaced — swapping moves is a player
## choice this project doesn't have a UI for yet, so the move is simply not added.
func grant_move(move_id: String) -> void:
	if move_id in equipped_move_deck:
		return
	if equipped_move_deck.size() >= MAX_MOVE_DECK_SIZE:
		return
	equipped_move_deck.append(move_id)
	move_deck_changed.emit()

func set_world_flag(flag_name: String, value: bool) -> void:
	world_flags[flag_name] = value
	world_flag_changed.emit(flag_name, value)

func get_world_flag(flag_name: String, default: bool = false) -> bool:
	return world_flags.get(flag_name, default)

func get_zone_level() -> int:
	return unlocked_seals.size()

## Origins the player has mastered (their own starting origin, plus any origin whose seal
## they've unlocked). Used to populate Combatant.mastered_origins for redirect-stance gating.
func get_mastered_origins() -> Array[String]:
	var mastered: Array[String] = []
	if starting_origin != "":
		mastered.append(starting_origin)
	for origin_name in ORIGIN_SEAL_IDS:
		if has_seal(ORIGIN_SEAL_IDS[origin_name]) and origin_name not in mastered:
			mastered.append(origin_name)
	return mastered
