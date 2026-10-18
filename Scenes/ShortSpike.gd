class_name ShortSpike
extends Node

signal contact_reached(hit_position: Vector3)

@export var definition: HitActionDefinition

# Fallback values keep the scene usable if the Resource is temporarily
# unassigned in the Inspector. The Resource is the intended source of truth.
const DEFAULT_ANIMATION: StringName = &"SpikeTesting1/WeakSpikeFull"
const DEFAULT_FPS: float = 60.0
const DEFAULT_TAKEOFF_FRAME: int = 32
const DEFAULT_CONTACT_FRAME: int = 56
const DEFAULT_CONTACT_OFFSET: Vector3 = Vector3(-0.126932, 1.678935, 0.159825)
const DEFAULT_JUMP_VELOCITY: float = 10.0

@onready var _pawn: PawnClass = $"../../../.."
@onready var _del: ActionDelegator = $"../../.."

var _taking_off: bool = false
var _impact_shown: bool = false
var _checking_contact: bool = false


func _ready() -> void:
	if definition == null:
		push_warning("ShortSpike has no HitActionDefinition assigned; using fallback spike settings.")
	elif not definition.is_valid_definition():
		push_warning("ShortSpike's HitActionDefinition has invalid settings.")


func jump() -> void:
	if _checking_contact:
		return

	_taking_off = true
	_checking_contact = true
	_impact_shown = false
	_pawn.pawn_animation.play_anim(_get_animation_name())


func _get_animation_name() -> StringName:
	return definition.animation_name if definition != null else DEFAULT_ANIMATION


func _get_animation_fps() -> float:
	return maxf(definition.animation_fps, 1.0) if definition != null else DEFAULT_FPS


func _get_takeoff_frame() -> int:
	return definition.takeoff_frame if definition != null else DEFAULT_TAKEOFF_FRAME


func _get_contact_frame() -> int:
	return definition.contact_frame if definition != null else DEFAULT_CONTACT_FRAME


func _get_contact_offset() -> Vector3:
	return definition.contact_offset if definition != null else DEFAULT_CONTACT_OFFSET


func get_takeoff_time() -> float:
	return float(_get_takeoff_frame()) / _get_animation_fps()


func get_contact_time() -> float:
	return float(_get_contact_frame()) / _get_animation_fps()


func get_contact_position() -> Vector3:
	return _pawn.global_transform * _get_contact_offset()


func get_jump_velocity() -> float:
	return definition.jump_velocity if definition != null else DEFAULT_JUMP_VELOCITY


func get_time_until_contact() -> float:
	var remaining := get_contact_time() - _pawn.pawn_animation.get_animation_position()
	return maxf(remaining, 0.0)


func _physics_process(_delta: float) -> void:
	if _taking_off:
		var current_frame := floori(
			_pawn.pawn_animation.get_animation_position() * _get_animation_fps()
		)

		if current_frame >= _get_takeoff_frame():
			_taking_off = false
			_pawn.velocity.y = get_jump_velocity()

	_update_contact_effect()


func _update_contact_effect() -> void:
	if not _checking_contact or _impact_shown:
		return

	var current_frame := floori(
		_pawn.pawn_animation.get_animation_position() * _get_animation_fps()
	)

	if current_frame < _get_contact_frame():
		return

	var hit_position: Vector3 = _pawn.pawn_animation.get_contact_position()
	contact_reached.emit(hit_position)
	_del.show_impact_sprite(hit_position)

	_impact_shown = true
	_checking_contact = false
