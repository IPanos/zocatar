extends Node

const BASE_LEVEL_DEFAULT: int = 5
const SEAL_LEVEL_MULTIPLIER: int = 8

func _ready() -> void:
	name = "ScalingEngine"

## ScaleLevel = BaseLevel + (Seals * 8)
func get_scale_level(base_level: int = BASE_LEVEL_DEFAULT) -> int:
	return base_level + (GameState.unlocked_seals.size() * SEAL_LEVEL_MULTIPLIER)

## Final boss origin is always the elemental opposite of the player's starting origin.
func get_final_boss_origin() -> String:
	return GameState.OPPOSITE_ORIGIN.get(GameState.starting_origin, "")
