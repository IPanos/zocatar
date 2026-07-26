extends RefCounted

class_name CombatantFactory

# GameState.equipped_move_deck has no starter moves yet (only the 5 sub-discipline reward
# moves exist) — this fallback keeps the battle scene testable until base movesets are designed.
const FALLBACK_TEST_MOVE_ID: String = "move_arc_flash"

static func build_player_combatant() -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = "Player"
	combatant.origin = GameState.starting_origin
	combatant.mastered_origins = GameState.get_mastered_origins()
	combatant.max_hp = 100 + ScalingEngine.get_scale_level() * 2
	combatant.max_chi = 100
	combatant.defense = 5
	var move_ids: Array = GameState.equipped_move_deck
	if move_ids.is_empty():
		move_ids = [FALLBACK_TEST_MOVE_ID]
	combatant.moves = _load_moves(move_ids)
	return combatant

static func build_test_enemy_combatant(origin_name: String = "Pyre") -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = "%s Trainee" % origin_name
	combatant.origin = origin_name
	combatant.mastered_origins = [origin_name]
	combatant.max_hp = 80
	combatant.max_chi = 80
	combatant.defense = 3
	combatant.moves = _load_moves([FALLBACK_TEST_MOVE_ID])
	return combatant

static func _load_moves(move_ids: Array) -> Array[Move]:
	var moves: Array[Move] = []
	for move_id in move_ids:
		var move := Move.load_from_file("res://data/moves/%s.json" % move_id)
		if move != null:
			moves.append(move)
	return moves
