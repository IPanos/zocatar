extends Node

class_name Combatant

signal hp_changed(current: int, max: int)
signal chi_changed(current: int, max: int)
signal status_applied(status: StatusEffect.Type, duration: int)
signal status_cleared(status: StatusEffect.Type)
signal defeated()

@export var display_name: String = ""
@export var origin: String = ""
@export var max_hp: int = 100
@export var max_chi: int = 100
@export var defense: int = 0
@export var moves: Array[Move] = []
# Origins whose seal this combatant has mastered — gates redirect-stance moves.
@export var mastered_origins: Array[String] = []

var current_hp: int
var current_chi: int
var active_statuses: Dictionary = {}
var evasion_bonus: float = 0.0
var is_redirecting: bool = false
var is_puppeted: bool = false
var puppet_duration: int = 0

func _ready() -> void:
	current_hp = max_hp
	current_chi = max_chi

func is_alive() -> bool:
	return current_hp > 0

func is_actionable() -> bool:
	return not has_status(StatusEffect.Type.STUN) and not has_status(StatusEffect.Type.FREEZE)

func apply_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		defeated.emit()

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)

func spend_chi(amount: int) -> bool:
	if current_chi < amount:
		return false
	current_chi -= amount
	chi_changed.emit(current_chi, max_chi)
	return true

func regen_chi(amount: int) -> void:
	current_chi = min(max_chi, current_chi + amount)
	chi_changed.emit(current_chi, max_chi)

func apply_status(status: StatusEffect.Type, duration: int = -1) -> void:
	if status == StatusEffect.Type.NONE:
		return
	var actual_duration: int = duration if duration > 0 else StatusEffect.DEFAULT_DURATION.get(status, 1)
	active_statuses[status] = actual_duration
	status_applied.emit(status, actual_duration)

func has_status(status: StatusEffect.Type) -> bool:
	return active_statuses.has(status)

func tick_statuses() -> void:
	for status in active_statuses.keys().duplicate():
		active_statuses[status] -= 1
		if active_statuses[status] <= 0:
			active_statuses.erase(status)
			status_cleared.emit(status)

func apply_self_buff(buff: Dictionary) -> void:
	if buff.has("evasion_boost"):
		evasion_bonus += buff["evasion_boost"]

func has_mastered(origin_name: String) -> bool:
	return origin_name in mastered_origins

func set_redirect_stance(active: bool) -> void:
	is_redirecting = active

func apply_control(duration: int) -> void:
	is_puppeted = true
	puppet_duration = duration

func tick_puppet() -> void:
	if not is_puppeted:
		return
	puppet_duration -= 1
	if puppet_duration <= 0:
		is_puppeted = false
		puppet_duration = 0
