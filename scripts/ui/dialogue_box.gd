extends Control

@onready var speaker_label: Label = $SpeakerLabel
@onready var text_label: Label = $TextLabel
@onready var choices_container: VBoxContainer = $ChoicesContainer

func _ready() -> void:
	visible = false
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.line_shown.connect(_on_line_shown)
	DialogueManager.choices_presented.connect(_on_choices_presented)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_dialogue_id: String) -> void:
	visible = true
	_clear_choices()

func _on_line_shown(speaker_name: String, _portrait_id: String, text: String) -> void:
	speaker_label.text = speaker_name
	text_label.text = text
	_clear_choices()

func _on_choices_presented(choices: Array) -> void:
	_clear_choices()
	for i in choices.size():
		var choice: Dictionary = choices[i]
		var button := Button.new()
		button.text = choice.get("text", "")
		button.pressed.connect(DialogueManager.select_choice.bind(i))
		choices_container.add_child(button)

func _on_dialogue_ended() -> void:
	visible = false
	_clear_choices()

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or choices_container.get_child_count() > 0:
		return
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
		DialogueManager.advance()
		get_viewport().set_input_as_handled()
