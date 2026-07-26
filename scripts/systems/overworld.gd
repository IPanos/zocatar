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

# Single shared placeholder trigger point until real per-origin starting maps/art exist.
# (12, 8) is the one grid coordinate the narrative spec actually gave — the Aether balcony
# boundary — reused here as a stand-in for all four origins' act-1 story NPC.
const STORY_TRIGGER_CELL: Vector2i = Vector2i(12, 8)
const CELL_SIZE: int = 16

# Placeholder room bounds (inclusive), painted procedurally since no real tile art/level
# layout exists yet. Bordered with the wall tile; floor tile color is origin-tinted, the
# one differentiation four distinct starting maps would otherwise provide.
const ROOM_MIN: Vector2i = Vector2i(6, 4)
const ROOM_MAX: Vector2i = Vector2i(18, 14)

const WALL_ATLAS_COORD: Vector2i = Vector2i(0, 0)
const FLOOR_ATLAS_COORD_BY_ORIGIN: Dictionary = {
	"Aether": Vector2i(1, 0),
	"Tide": Vector2i(2, 0),
	"Terra": Vector2i(3, 0),
	"Pyre": Vector2i(4, 0),
}

@onready var tile_map: TileMap = $TileMap
@onready var player: PlayerController = $Player
@onready var virtual_controls: VirtualDPad = $UI/VirtualControls
@onready var story_npc: Node2D = $NPCs/StoryNPC

func _ready() -> void:
	_paint_room()
	story_npc.position = Vector2(
		STORY_TRIGGER_CELL.x * CELL_SIZE + CELL_SIZE / 2.0,
		STORY_TRIGGER_CELL.y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.is_cell_blocked = _is_cell_blocked
	player.interacted.connect(_on_player_interacted)
	virtual_controls.direction_pressed.connect(player.try_move)
	virtual_controls.action_pressed.connect(player.interact)

func _paint_room() -> void:
	var floor_coord: Vector2i = FLOOR_ATLAS_COORD_BY_ORIGIN.get(GameState.starting_origin, Vector2i(1, 0))
	for x in range(ROOM_MIN.x - 1, ROOM_MAX.x + 2):
		for y in range(ROOM_MIN.y - 1, ROOM_MAX.y + 2):
			var cell := Vector2i(x, y)
			var is_border: bool = x == ROOM_MIN.x - 1 or x == ROOM_MAX.x + 1 or y == ROOM_MIN.y - 1 or y == ROOM_MAX.y + 1
			var atlas_coord: Vector2i = WALL_ATLAS_COORD if is_border else floor_coord
			tile_map.set_cell(0, cell, 0, atlas_coord)

func _is_cell_blocked(cell: Vector2i) -> bool:
	if tile_map.get_cell_source_id(0, cell) == -1:
		return true
	return tile_map.get_cell_atlas_coords(0, cell) == WALL_ATLAS_COORD

func _on_player_interacted(facing_cell: Vector2i) -> void:
	if facing_cell != STORY_TRIGGER_CELL:
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
