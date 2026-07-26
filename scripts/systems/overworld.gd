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

func _ready() -> void:
	if GameState.starting_origin == "":
		return
	if GameState.get_world_flag("flag_main_%s_act1_started" % GameState.starting_origin.to_lower()):
		return
	var dialogue_path: String = ACT1_DIALOGUE_FILES.get(GameState.starting_origin, "")
	if dialogue_path == "":
		return
	DialogueManager.load_dialogue_file(dialogue_path)
	DialogueManager.start_dialogue(ACT1_START_NODE[GameState.starting_origin])
