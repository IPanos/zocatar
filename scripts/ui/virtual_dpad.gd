extends Control

class_name VirtualDPad

signal direction_pressed(direction: Vector2i)
signal action_pressed()

@onready var up_button: Button = $DPad/Up
@onready var down_button: Button = $DPad/Down
@onready var left_button: Button = $DPad/Left
@onready var right_button: Button = $DPad/Right
@onready var action_button: Button = $ActionButton

func _ready() -> void:
	up_button.pressed.connect(func(): direction_pressed.emit(Vector2i.UP))
	down_button.pressed.connect(func(): direction_pressed.emit(Vector2i.DOWN))
	left_button.pressed.connect(func(): direction_pressed.emit(Vector2i.LEFT))
	right_button.pressed.connect(func(): direction_pressed.emit(Vector2i.RIGHT))
	action_button.pressed.connect(func(): action_pressed.emit())
