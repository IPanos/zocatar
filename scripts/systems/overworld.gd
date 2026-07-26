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

@onready var player: PlayerController = $Player
@onready var virtual_controls: VirtualDPad = $UI/VirtualControls
@onready var story_npc: Node2D = $NPCs/StoryNPC

func _ready() -> void:
	story_npc.position = Vector2(
		STORY_TRIGGER_CELL.x * CELL_SIZE + CELL_SIZE / 2.0,
		STORY_TRIGGER_CELL.y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.interacted.connect(_on_player_interacted)
	virtual_controls.direction_pressed.connect(player.try_move)
	virtual_controls.action_pressed.connect(player.interact)

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
