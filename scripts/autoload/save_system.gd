extends Node

class_name SaveSystem

const SAVE_DIR = "user://saves/"
const SAVE_FILE = "user://saves/game.json"

func _ready() -> void:
	name = "SaveSystem"
	_ensure_save_directory()

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_abs_absolute(SAVE_DIR)

func save_game() -> bool:
	var game_data = {
		"starting_origin": GameState.starting_origin,
		"unlocked_seals": GameState.unlocked_seals,
		"equipped_move_deck": GameState.equipped_move_deck,
		"world_flags": GameState.world_flags,
		"timestamp": Time.get_ticks_msec()
	}

	var json_string = JSON.stringify(game_data)
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)

	if file == null:
		push_error("Failed to save game: ", FileAccess.get_open_error())
		return false

	file.store_string(json_string)
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE):
		push_warning("No save file found")
		return false

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("Failed to load game: ", FileAccess.get_open_error())
		return false

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("Failed to parse save file")
		return false

	var game_data = json.data as Dictionary
	GameState.starting_origin = game_data.get("starting_origin", "")
	GameState.unlocked_seals = game_data.get("unlocked_seals", [])
	GameState.equipped_move_deck = game_data.get("equipped_move_deck", [])
	GameState.world_flags = game_data.get("world_flags", {})

	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_FILE)
