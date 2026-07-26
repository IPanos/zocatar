extends CharacterBody2D

class_name PlayerController

signal moved(cell: Vector2i)
signal interacted(facing_cell: Vector2i)

const CELL_SIZE: int = 16
const MOVE_DURATION: float = 0.15

@export var grid_position: Vector2i = Vector2i(10, 10)

var facing: Vector2i = Vector2i.DOWN
var _is_moving: bool = false

# Overridable passability check — swapped for real TileMap collision once tile art/collision
# data exists. Defaults to "everything is walkable" since no tile collision layer exists yet.
var is_cell_blocked: Callable

func _ready() -> void:
	is_cell_blocked = _default_is_cell_blocked
	position = _cell_to_position(grid_position)

func _default_is_cell_blocked(_cell: Vector2i) -> bool:
	return false

func _unhandled_input(event: InputEvent) -> void:
	if _is_moving:
		return
	if event.is_action_pressed("ui_up"):
		try_move(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		try_move(Vector2i.DOWN)
	elif event.is_action_pressed("ui_left"):
		try_move(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		try_move(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_accept"):
		interact()

func try_move(direction: Vector2i) -> void:
	if _is_moving:
		return
	facing = direction
	var target_cell: Vector2i = grid_position + direction
	if is_cell_blocked.call(target_cell):
		return
	_is_moving = true
	grid_position = target_cell
	var tween := create_tween()
	tween.tween_property(self, "position", _cell_to_position(grid_position), MOVE_DURATION)
	tween.tween_callback(_on_move_finished)

func interact() -> void:
	interacted.emit(grid_position + facing)

func _on_move_finished() -> void:
	_is_moving = false
	moved.emit(grid_position)

func _cell_to_position(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2.0, cell.y * CELL_SIZE + CELL_SIZE / 2.0)
