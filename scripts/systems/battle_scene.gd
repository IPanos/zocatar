extends Node2D

@onready var player_team_node: Node = $PlayerTeam
@onready var enemy_team_node: Node = $EnemyTeam
@onready var battle_ui: CanvasLayer = $BattleUI

func _ready() -> void:
	var engine := BattleEngine.new()
	add_child(engine)

	var player := CombatantFactory.build_player_combatant()
	var enemy := CombatantFactory.build_test_enemy_combatant()
	player_team_node.add_child(player)
	enemy_team_node.add_child(enemy)

	battle_ui.bind(engine, player, enemy)
	engine.start_battle([player], [enemy], BattleEngine.Mode.DUEL_1V1)
