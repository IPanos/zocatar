extends Resource

class_name Move

@export var move_id: String = ""
@export var display_name: String = ""
@export var discipline: String = ""
@export var description: String = ""
@export var energy_cost: int = 0
@export var power: int = 0
@export var accuracy: float = 1.0
@export var status_effect: StatusEffect.Type = StatusEffect.Type.NONE
@export var status_chance: float = 0.0
@export var lifesteal_percent: float = 0.0
@export var ignore_defense: bool = false
# Self-applied buff on cast, e.g. {"evasion_boost": 0.25, "duration": 3} — consumed by BattleEngine.
@export var self_buff: Dictionary = {}

static func from_dict(data: Dictionary) -> Move:
	var move := Move.new()
	move.move_id = data.get("move_id", "")
	move.display_name = data.get("display_name", "")
	move.discipline = data.get("discipline", "")
	move.description = data.get("description", "")
	move.energy_cost = data.get("energy_cost", 0)
	move.power = data.get("power", 0)
	move.accuracy = data.get("accuracy", 1.0)
	move.status_effect = StatusEffect.type_from_string(data.get("status_effect", "none"))
	move.status_chance = data.get("status_chance", 0.0)
	move.lifesteal_percent = data.get("lifesteal_percent", 0.0)
	move.ignore_defense = data.get("ignore_defense", false)
	move.self_buff = data.get("self_buff", {})
	return move

static func load_from_file(path: String) -> Move:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Move: failed to open %s" % path)
		return null
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Move: invalid move file %s" % path)
		return null
	return from_dict(parsed)
