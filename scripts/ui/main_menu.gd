extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var load_game_button: Button = $VBoxContainer/LoadGameButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var donation_button: Button = $VBoxContainer/DonationButton

# Set once a support/donation URL is provided, then flip DonationButton.disabled to false.
const DONATION_URL: String = ""

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	load_game_button.disabled = not SaveSystem.has_save()
	quit_button.pressed.connect(_on_quit_pressed)
	settings_button.disabled = true
	settings_button.tooltip_text = "Coming soon"

	if DONATION_URL.is_empty():
		return
	donation_button.disabled = false
	donation_button.pressed.connect(_on_donation_pressed)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/origin_select.tscn")

func _on_load_game_pressed() -> void:
	if SaveSystem.load_game():
		get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_donation_pressed() -> void:
	OS.shell_open(DONATION_URL)
