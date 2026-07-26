extends RefCounted

class_name StatusEffect

enum Type { NONE, STUN, BURN, FREEZE, ROOT }

const DEFAULT_DURATION: Dictionary = {
	Type.STUN: 1,
	Type.BURN: 3,
	Type.FREEZE: 2,
	Type.ROOT: 2,
}

static func type_from_string(status_name: String) -> Type:
	match status_name.to_lower():
		"stun": return Type.STUN
		"burn": return Type.BURN
		"freeze": return Type.FREEZE
		"root": return Type.ROOT
		_: return Type.NONE
