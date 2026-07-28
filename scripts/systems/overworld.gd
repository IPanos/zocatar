extends Node2D

const ACT1_DIALOGUE_FILES: Dictionary = {
	"Aether": "res://data/dialogue/main_aether_act1.json",
	"Tide": "res://data/dialogue/main_tide_act1.json",
	"Terra": "res://data/dialogue/main_terra_act1.json",
	"Pyre": "res://data/dialogue/main_pyre_act1.json",
}

const ACT1_START_NODE: Dictionary = {
	"Aether": "aether_act1_siege_01",
	"Tide": "tide_act1_01",
	"Terra": "terra_act1_01",
	"Pyre": "pyre_act1_01",
}

const CELL_SIZE: int = 16

const WALL: Vector2i = Vector2i(0, 0)
const FLOOR_AETHER: Vector2i = Vector2i(1, 0)
const FLOOR_TIDE: Vector2i = Vector2i(2, 0)
const FLOOR_TERRA: Vector2i = Vector2i(3, 0)
const FLOOR_PYRE: Vector2i = Vector2i(4, 0)
const WATER: Vector2i = Vector2i(5, 0)
const OBSTACLE: Vector2i = Vector2i(6, 0)
const BLOCKING_COORDS: Array[Vector2i] = [WALL, WATER, OBSTACLE]

# Shared bounding box for all four placeholder maps — the shape of each is carved out
# from within these bounds, not the rectangle itself. No hand-authored art exists yet,
# so each layout is a small procedural pattern rather than a real level.
const BOUNDS_MIN: Vector2i = Vector2i(6, 4)
const BOUNDS_MAX: Vector2i = Vector2i(18, 14)

# origin -> { floor: atlas coord, trigger_cell: where the story NPC stands, blocked: extra
# water/obstacle cells layered on top of the plain floor+wall-border shared by all layouts }
# Not a const — GDScript doesn't allow lambda literals in constant expressions.
var LAYOUTS: Dictionary = {
	# Gale Crest Monastery: a canyon drop carved out of the SE corner turns the room into
	# an L-shaped balcony. Trigger cell (12, 8) is the one grid coordinate the narrative
	# spec actually gave (the Aether balcony boundary).
	"Aether": {
		"floor": FLOOR_AETHER,
		"blocked_tile": WATER,
		"trigger_cell": Vector2i(12, 8),
		"blocked": func(cell: Vector2i) -> bool:
			return cell.x >= 13 and cell.y >= 10,
	},
	# Frost Haven Pier: a two-plank-wide walkway over open water.
	"Tide": {
		"floor": FLOOR_TIDE,
		"blocked_tile": WATER,
		"trigger_cell": Vector2i(16, 9),
		"blocked": func(cell: Vector2i) -> bool:
			return cell.y != 9 and cell.y != 10,
	},
	# Bouldergate Quarry: open floor scattered with immovable boulders.
	"Terra": {
		"floor": FLOOR_TERRA,
		"blocked_tile": OBSTACLE,
		"trigger_cell": Vector2i(12, 8),
		"blocked": func(cell: Vector2i) -> bool:
			var boulders: Array[Vector2i] = [
				Vector2i(9, 6), Vector2i(9, 9), Vector2i(12, 6), Vector2i(12, 11),
				Vector2i(15, 7), Vector2i(15, 10), Vector2i(17, 5), Vector2i(9, 12),
			]
			return cell in boulders,
	},
	# Ashfall Docks: two rows of crates forming an aisle toward the warship.
	"Pyre": {
		"floor": FLOOR_PYRE,
		"blocked_tile": OBSTACLE,
		"trigger_cell": Vector2i(16, 8),
		"blocked": func(cell: Vector2i) -> bool:
			return (cell.x == 9 or cell.x == 15) and (cell.y < 8 or cell.y > 10),
	},
}

const DEFAULT_ORIGIN: String = "Aether"

@onready var tile_map: TileMap = $TileMap
@onready var player: PlayerController = $Player
@onready var virtual_controls: VirtualDPad = $UI/VirtualControls
@onready var story_npc: Node2D = $NPCs/StoryNPC

var _trigger_cell: Vector2i

func _ready() -> void:
	var layout: Dictionary = LAYOUTS.get(GameState.starting_origin, LAYOUTS[DEFAULT_ORIGIN])
	_trigger_cell = layout["trigger_cell"]
	_paint_room(layout)
	story_npc.position = Vector2(
		_trigger_cell.x * CELL_SIZE + CELL_SIZE / 2.0,
		_trigger_cell.y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.is_cell_blocked = _is_cell_blocked
	player.interacted.connect(_on_player_interacted)
	virtual_controls.direction_pressed.connect(player.try_move)
	virtual_controls.action_pressed.connect(player.interact)
	DialogueManager.battle_triggered.connect(_on_battle_triggered)
	# Hide the D-pad/action overlay during dialogue — it was rendering on top of the
	# dialogue box (both occupy the bottom of the screen) and its buttons would eat
	# taps meant to advance text, moving the player instead.
	DialogueManager.dialogue_started.connect(func(_id): virtual_controls.visible = false)
	DialogueManager.dialogue_ended.connect(func(): virtual_controls.visible = true)

func _paint_room(layout: Dictionary) -> void:
	var floor_coord: Vector2i = layout["floor"]
	var blocked_tile: Vector2i = layout["blocked_tile"]
	var is_blocked: Callable = layout["blocked"]
	for x in range(BOUNDS_MIN.x - 1, BOUNDS_MAX.x + 2):
		for y in range(BOUNDS_MIN.y - 1, BOUNDS_MAX.y + 2):
			var cell := Vector2i(x, y)
			var is_border: bool = x == BOUNDS_MIN.x - 1 or x == BOUNDS_MAX.x + 1 or y == BOUNDS_MIN.y - 1 or y == BOUNDS_MAX.y + 1
			var atlas_coord: Vector2i
			if is_border:
				atlas_coord = WALL
			elif is_blocked.call(cell):
				atlas_coord = blocked_tile
			else:
				atlas_coord = floor_coord
			tile_map.set_cell(0, cell, 0, atlas_coord)

func _is_cell_blocked(cell: Vector2i) -> bool:
	if tile_map.get_cell_source_id(0, cell) == -1:
		return true
	return tile_map.get_cell_atlas_coords(0, cell) in BLOCKING_COORDS

func _on_player_interacted(facing_cell: Vector2i) -> void:
	if facing_cell != _trigger_cell:
		return
	_play_act1_intro()

func _play_act1_intro() -> void:
	if GameState.starting_origin == "":
		return
	if GameState.get_world_flag("flag_main_%s_act1_started" % GameState.starting_origin.to_lower()):
		return
	var dialogue_path: String = ACT1_DIALOGUE_FILES.get(GameState.starting_origin, "")
	if dialogue_path == "":
		return
	DialogueManager.load_dialogue_file(dialogue_path)
	DialogueManager.start_dialogue(ACT1_START_NODE[GameState.starting_origin])

func _on_battle_triggered(encounter_id: String) -> void:
	GameState.pending_battle_encounter = encounter_id
	get_tree().change_scene_to_file("res://scenes/battle/battle_engine.tscn")
