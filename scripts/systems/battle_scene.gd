extends Node2D

const RETURN_TO_OVERWORLD_DELAY: float = 2.0

@onready var player_team_node: Node = $PlayerTeam
@onready var enemy_team_node: Node = $EnemyTeam
@onready var battle_ui: CanvasLayer = $BattleUI

func _ready() -> void:
	var engine := BattleEngine.new()
	add_child(engine)

	var player := CombatantFactory.build_player_combatant()
	var enemy := CombatantFactory.build_encounter_enemy_combatant()
	player_team_node.add_child(player)
	enemy_team_node.add_child(enemy)

	battle_ui.bind(engine, player, enemy)
	engine.battle_ended.connect(_on_battle_ended)
	engine.start_battle([player], [enemy], BattleEngine.Mode.DUEL_1V1)

func _on_battle_ended(_player_won: bool) -> void:
	GameState.pending_battle_encounter = ""
	await get_tree().create_timer(RETURN_TO_OVERWORLD_DELAY).timeout
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")
