class_name PawnOrientation extends Node

@export var turn_speed: float = 8.0

@onready var _pawn: PawnClass = $"../.."

var _target_object: Node3D

func set_target_object(target: Node3D) -> void:
	_target_object = target

func clear_target() -> void:
	_target_object = null

func tick(delta: float) -> void:
	if not is_instance_valid(_target_object):
		_target_object = null
		return

	var direction: Vector3 = _target_object.global_position - _pawn.global_position
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		return

	var target_rotation := atan2(direction.x, direction.z)
	_pawn.rotation.y = lerp_angle(
		_pawn.rotation.y,
		target_rotation,
		clampf(turn_speed * delta, 0.0, 1.0)
	)
