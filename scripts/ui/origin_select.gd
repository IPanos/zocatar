extends Control

@onready var buttons_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	for child in buttons_container.get_children():
		if child is Button and child.has_meta("origin"):
			child.pressed.connect(_on_origin_pressed.bind(child.get_meta("origin")))

func _on_origin_pressed(origin: String) -> void:
	GameState.set_starting_origin(origin)
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")
