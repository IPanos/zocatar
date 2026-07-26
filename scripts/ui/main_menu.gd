extends Control

@onready var donation_button: Button = $VBoxContainer/DonationButton

# Set once a support/donation URL is provided, then flip DonationButton.disabled to false.
const DONATION_URL: String = ""

func _ready() -> void:
	if DONATION_URL.is_empty():
		return
	donation_button.disabled = false
	donation_button.pressed.connect(_on_donation_pressed)

func _on_donation_pressed() -> void:
	OS.shell_open(DONATION_URL)
