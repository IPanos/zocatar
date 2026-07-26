extends Node

class_name BattleEngine

enum Mode { DUEL_1V1, DUEL_3V3 }

const BURN_DAMAGE_PERCENT: float = 0.05
const CHI_REGEN_PERCENT: float = 0.1

signal battle_started(mode: Mode)
signal turn_started(active: Combatant)
signal move_used(user: Combatant, move: Move, target: Combatant)
signal damage_dealt(target: Combatant, amount: int)
signal status_ticked(target: Combatant, status: StatusEffect.Type)
signal combatant_defeated(combatant: Combatant)
signal battle_ended(player_won: bool)

var mode: Mode = Mode.DUEL_1V1
var player_team: Array[Combatant] = []
var enemy_team: Array[Combatant] = []
var active_player: Combatant
var active_enemy: Combatant

var _battle_over: bool = false

func start_battle(p_team: Array[Combatant], e_team: Array[Combatant], p_mode: Mode = Mode.DUEL_1V1) -> void:
	player_team = p_team
	enemy_team = e_team
	mode = p_mode
	_battle_over = false
	active_player = _get_next_alive(player_team)
	active_enemy = _get_next_alive(enemy_team)
	battle_started.emit(mode)
	turn_started.emit(active_player)

## Called by the UI/AI layer once a side has chosen its move for this turn.
func submit_move(user: Combatant, move: Move, target: Combatant) -> bool:
	if _battle_over or not user.is_alive() or not user.is_actionable():
		return false
	if move not in user.moves:
		return false
	if not user.spend_chi(move.energy_cost):
		return false

	move_used.emit(user, move, target)

	if move.self_buff.size() > 0:
		user.apply_self_buff(move.self_buff)

	if move.power > 0 and randf() <= (move.accuracy - target.evasion_bonus):
		var raw_damage: int = move.power if move.ignore_defense else max(1, move.power - target.defense)
		target.apply_damage(raw_damage)
		damage_dealt.emit(target, raw_damage)
		if move.lifesteal_percent > 0.0:
			user.heal(int(raw_damage * move.lifesteal_percent))
		if move.status_effect != StatusEffect.Type.NONE and randf() <= move.status_chance:
			target.apply_status(move.status_effect)

	if not target.is_alive():
		combatant_defeated.emit(target)
		_handle_defeat(target)

	if not _battle_over:
		_advance_to_next_turn(user)
	return true

func _advance_to_next_turn(last_actor: Combatant) -> void:
	# Check team membership rather than identity against active_player/active_enemy —
	# a defeat this turn may already have swapped the active combatant for that side.
	if last_actor in player_team:
		turn_started.emit(active_enemy)
	else:
		_end_round()

func _end_round() -> void:
	for combatant in [active_player, active_enemy]:
		if not combatant.is_alive():
			continue
		if combatant.has_status(StatusEffect.Type.BURN):
			var burn_damage: int = int(combatant.max_hp * BURN_DAMAGE_PERCENT)
			combatant.apply_damage(burn_damage)
			status_ticked.emit(combatant, StatusEffect.Type.BURN)
			if not combatant.is_alive():
				combatant_defeated.emit(combatant)
				_handle_defeat(combatant)
		combatant.tick_statuses()
		combatant.regen_chi(int(combatant.max_chi * CHI_REGEN_PERCENT))
	if not _battle_over:
		turn_started.emit(active_player)

func _handle_defeat(fallen: Combatant) -> void:
	var team: Array[Combatant] = player_team if fallen in player_team else enemy_team
	var replacement: Combatant = _get_next_alive(team)
	if replacement == null:
		_end_battle(fallen in enemy_team)
		return
	# 3v3 team-swap: replacement becomes active, but the UI hook for the player to
	# choose which teammate swaps in isn't built yet — this always takes the first alive.
	if fallen in player_team:
		active_player = replacement
	else:
		active_enemy = replacement

func _get_next_alive(team: Array[Combatant]) -> Combatant:
	for combatant in team:
		if combatant.is_alive():
			return combatant
	return null

func _end_battle(player_won: bool) -> void:
	_battle_over = true
	battle_ended.emit(player_won)
