extends Node

class_name DialogueManager

signal dialogue_started(dialogue_id: String)
signal line_shown(speaker_name: String, portrait_id: String, text: String)
signal choices_presented(choices: Array)
signal dialogue_ended()
signal sfx_cued(sfx_id: String)
signal battle_triggered(encounter_id: String)
signal move_granted(move_id: String)

var dialogue_nodes: Dictionary = {}

var current_dialogue_id: String = ""
var current_node: Dictionary = {}
var current_line_index: int = -1

func load_dialogue_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DialogueManager: failed to open %s" % path)
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueManager: invalid dialogue file %s" % path)
		return
	for dialogue_id in parsed.keys():
		dialogue_nodes[dialogue_id] = parsed[dialogue_id]

func start_dialogue(dialogue_id: String) -> void:
	if not dialogue_nodes.has(dialogue_id):
		push_error("DialogueManager: unknown dialogue_id %s" % dialogue_id)
		return
	dialogue_started.emit(dialogue_id)
	_goto_node(dialogue_id)

func advance() -> void:
	if current_node.is_empty():
		return
	var lines: Array = current_node.get("lines", [])
	current_line_index += 1
	if current_line_index < lines.size():
		line_shown.emit(current_node.get("speaker_name", ""), current_node.get("portrait_id", ""), lines[current_line_index])
		return
	_complete_node()

func select_choice(index: int) -> void:
	var choices: Array = current_node.get("choices", [])
	if index < 0 or index >= choices.size():
		return
	var next_id: Variant = choices[index].get("next_dialogue_id")
	_advance_to_next(next_id)

func _goto_node(dialogue_id: String) -> void:
	current_dialogue_id = dialogue_id
	current_node = dialogue_nodes[dialogue_id]
	current_line_index = -1
	# sets_flag and sfx fire as soon as the node becomes current, per spec ("when node is reached" / "when node starts").
	if current_node.get("sfx"):
		sfx_cued.emit(current_node["sfx"])
	if current_node.get("sets_flag"):
		GameState.set_world_flag(current_node["sets_flag"], true)
	if current_node.get("sets_flags"):
		for flag_name in current_node["sets_flags"]:
			GameState.set_world_flag(flag_name, true)
	advance()

func _complete_node() -> void:
	# triggers_battle / grants_move fire once all lines have been shown, i.e. when the node "completes".
	if current_node.get("triggers_battle"):
		battle_triggered.emit(current_node["triggers_battle"])
	if current_node.get("grants_move"):
		move_granted.emit(current_node["grants_move"])
	var choices: Array = current_node.get("choices", [])
	if choices.size() > 0:
		choices_presented.emit(choices)
		return
	_advance_to_next(current_node.get("next_dialogue_id"))

func _advance_to_next(next_id: Variant) -> void:
	if next_id == null or next_id == "":
		_end_dialogue()
		return
	if not dialogue_nodes.has(next_id):
		push_error("DialogueManager: unknown next_dialogue_id %s" % str(next_id))
		_end_dialogue()
		return
	_goto_node(next_id)

func _end_dialogue() -> void:
	current_node = {}
	current_dialogue_id = ""
	current_line_index = -1
	dialogue_ended.emit()
