extends CanvasLayer

@onready var player_hp_bar: ProgressBar = $HealthBars/PlayerHealthBar
@onready var player_chi_bar: ProgressBar = $HealthBars/PlayerChiBar
@onready var enemy_hp_bar: ProgressBar = $HealthBars/EnemyHealthBar
@onready var enemy_chi_bar: ProgressBar = $HealthBars/EnemyChiBar
@onready var player_status_label: Label = $StatusIndicators/PlayerStatusLabel
@onready var enemy_status_label: Label = $StatusIndicators/EnemyStatusLabel
@onready var move_buttons_container: VBoxContainer = $MoveSelector/MoveButtons
@onready var message_label: Label = $MessageLabel

var _engine: BattleEngine
var _player: Combatant
var _enemy: Combatant

func bind(engine: BattleEngine, player: Combatant, enemy: Combatant) -> void:
	_engine = engine
	_player = player
	_enemy = enemy

	player.hp_changed.connect(func(cur, max_hp): player_hp_bar.max_value = max_hp; player_hp_bar.value = cur)
	player.chi_changed.connect(func(cur, max_chi): player_chi_bar.max_value = max_chi; player_chi_bar.value = cur)
	enemy.hp_changed.connect(func(cur, max_hp): enemy_hp_bar.max_value = max_hp; enemy_hp_bar.value = cur)
	enemy.chi_changed.connect(func(cur, max_chi): enemy_chi_bar.max_value = max_chi; enemy_chi_bar.value = cur)

	player.status_applied.connect(func(_s, _d): _refresh_status_label(player_status_label, player))
	player.status_cleared.connect(func(_s): _refresh_status_label(player_status_label, player))
	enemy.status_applied.connect(func(_s, _d): _refresh_status_label(enemy_status_label, enemy))
	enemy.status_cleared.connect(func(_s): _refresh_status_label(enemy_status_label, enemy))

	engine.turn_started.connect(_on_turn_started)
	engine.turn_skipped.connect(func(actor): _log("%s's turn is skipped!" % actor.display_name))
	engine.move_used.connect(func(user, move, _t): _log("%s uses %s!" % [user.display_name, move.display_name]))
	engine.damage_dealt.connect(func(target, amount): _log("%s takes %d damage." % [target.display_name, amount]))
	engine.redirect_stance_taken.connect(func(user): _log("%s braces to redirect the next hit!" % user.display_name))
	engine.redirect_failed.connect(func(user, dmg): _log("%s fumbles the redirect and takes %d damage!" % [user.display_name, dmg]))
	engine.move_redirected.connect(func(attacker, redirector): _log("%s redirects the attack back at %s!" % [redirector.display_name, attacker.display_name]))
	engine.control_applied.connect(func(target, _d): _log("%s is being controlled!" % target.display_name))
	engine.puppet_forced_move.connect(_on_puppet_forced_move)
	engine.combatant_defeated.connect(func(combatant): _log("%s is defeated!" % combatant.display_name))
	engine.battle_ended.connect(_on_battle_ended)

	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.current_hp
	player_chi_bar.max_value = player.max_chi
	player_chi_bar.value = player.current_chi
	enemy_hp_bar.max_value = enemy.max_hp
	enemy_hp_bar.value = enemy.current_hp
	enemy_chi_bar.max_value = enemy.max_chi
	enemy_chi_bar.value = enemy.current_chi

func _on_turn_started(actor: Combatant) -> void:
	if actor == _player:
		_show_move_buttons()
	else:
		_clear_move_buttons()

func _show_move_buttons() -> void:
	_clear_move_buttons()
	for move in _player.moves:
		var button := Button.new()
		button.text = "%s (Chi %d)" % [move.display_name, move.energy_cost]
		button.pressed.connect(_on_move_pressed.bind(move))
		move_buttons_container.add_child(button)

func _clear_move_buttons() -> void:
	for child in move_buttons_container.get_children():
		child.queue_free()

func _on_move_pressed(move: Move) -> void:
	_engine.submit_move(_player, move, _enemy)

func _on_puppet_forced_move(puppet: Combatant, move: Move, target: Combatant) -> void:
	if move != null and target != null:
		_log("%s is forced to use %s on %s!" % [puppet.display_name, move.display_name, target.display_name])

func _on_battle_ended(player_won: bool) -> void:
	_log("Victory!" if player_won else "Defeat...")
	_clear_move_buttons()

func _refresh_status_label(label: Label, combatant: Combatant) -> void:
	var names: Array[String] = []
	for status in combatant.active_statuses.keys():
		names.append(StatusEffect.Type.keys()[status])
	label.text = ", ".join(PackedStringArray(names))

func _log(text: String) -> void:
	message_label.text = text
