extends Node

class_name BattleEngine

enum Mode { DUEL_1V1, DUEL_3V3 }

const BURN_DAMAGE_PERCENT: float = 0.05
const CHI_REGEN_PERCENT: float = 0.1
const REDIRECT_BACKFIRE_PERCENT: float = 0.15

signal battle_started(mode: Mode)
signal turn_started(active: Combatant)
signal turn_skipped(actor: Combatant)
signal move_used(user: Combatant, move: Move, target: Combatant)
signal damage_dealt(target: Combatant, amount: int)
signal status_ticked(target: Combatant, status: StatusEffect.Type)
signal combatant_defeated(combatant: Combatant)
signal battle_ended(player_won: bool)
signal redirect_stance_taken(user: Combatant)
signal redirect_failed(user: Combatant, backfire_damage: int)
signal move_redirected(original_attacker: Combatant, redirector: Combatant)
signal control_applied(target: Combatant, duration: int)
signal puppet_forced_move(puppet: Combatant, move: Move, forced_target: Combatant)

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
	_begin_turn(active_player)

## Called by the UI/AI layer once a side has chosen its move for this turn.
func submit_move(user: Combatant, move: Move, target: Combatant) -> bool:
	if _battle_over or not user.is_alive() or not user.is_actionable() or user.is_puppeted:
		return false
	if move not in user.moves:
		return false
	if not user.spend_chi(move.energy_cost):
		return false
	_execute_move(user, move, target)
	if not _battle_over:
		_advance_to_next_turn(user)
	return true

## Shared resolution path for both player/AI-submitted moves and puppet-forced moves.
func _execute_move(user: Combatant, move: Move, target: Combatant) -> void:
	move_used.emit(user, move, target)

	if move.is_redirect_stance:
		if move.redirect_requires_origin == "" or user.has_mastered(move.redirect_requires_origin):
			user.set_redirect_stance(true)
			redirect_stance_taken.emit(user)
		else:
			var backfire_damage: int = int(user.max_hp * REDIRECT_BACKFIRE_PERCENT)
			user.apply_damage(backfire_damage)
			redirect_failed.emit(user, backfire_damage)
			if not user.is_alive():
				combatant_defeated.emit(user)
				_handle_defeat(user)
		return

	if move.self_buff.size() > 0:
		user.apply_self_buff(move.self_buff)

	if move.power <= 0 or randf() > (move.accuracy - target.evasion_bonus):
		return

	var actual_attacker: Combatant = user
	var actual_target: Combatant = target
	if target.is_redirecting:
		target.set_redirect_stance(false)
		actual_attacker = target
		actual_target = user
		move_redirected.emit(user, target)

	var raw_damage: int = move.power if move.ignore_defense else max(1, move.power - actual_target.defense)
	actual_target.apply_damage(raw_damage)
	damage_dealt.emit(actual_target, raw_damage)

	if move.lifesteal_percent > 0.0:
		actual_attacker.heal(int(raw_damage * move.lifesteal_percent))
	if move.status_effect != StatusEffect.Type.NONE and randf() <= move.status_chance:
		actual_target.apply_status(move.status_effect)
	if move.applies_control and randf() <= move.control_chance:
		actual_target.apply_control(move.control_duration)
		control_applied.emit(actual_target, move.control_duration)

	if not actual_target.is_alive():
		combatant_defeated.emit(actual_target)
		_handle_defeat(actual_target)

## A puppeted combatant is forced to use one of their own moves against their own side.
func _resolve_puppeted_turn(puppet: Combatant) -> void:
	var team: Array[Combatant] = player_team if puppet in player_team else enemy_team
	var allies: Array[Combatant] = team.filter(func(c): return c != puppet and c.is_alive())
	if allies.is_empty() or puppet.moves.is_empty():
		puppet_forced_move.emit(puppet, null, null)
		if not _battle_over:
			_advance_to_next_turn(puppet)
		return
	var forced_move: Move = puppet.moves[randi() % puppet.moves.size()]
	var forced_target: Combatant = allies[randi() % allies.size()]
	puppet.spend_chi(forced_move.energy_cost)
	_execute_move(puppet, forced_move, forced_target)
	puppet_forced_move.emit(puppet, forced_move, forced_target)
	if not _battle_over:
		_advance_to_next_turn(puppet)

func _begin_turn(actor: Combatant) -> void:
	turn_started.emit(actor)
	if actor.is_redirecting:
		actor.set_redirect_stance(false)
	if not actor.is_actionable():
		turn_skipped.emit(actor)
		_advance_to_next_turn(actor)
		return
	if actor.is_puppeted:
		_resolve_puppeted_turn(actor)
		return
	# Otherwise: wait for an external submit_move() call.

func _advance_to_next_turn(last_actor: Combatant) -> void:
	# Check team membership rather than identity against active_player/active_enemy —
	# a defeat this turn may already have swapped the active combatant for that side.
	if last_actor in player_team:
		_begin_turn(active_enemy)
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
		combatant.tick_puppet()
		combatant.regen_chi(int(combatant.max_chi * CHI_REGEN_PERCENT))
	if not _battle_over:
		_begin_turn(active_player)

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
