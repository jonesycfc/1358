
class_name HitActionBase
extends Node

signal contact_completed(ball: BallScriptAnima)
signal action_finished

@export var definition: HitActionDefinition

@onready var _pawn: PawnClass = $"../../.."
@onready var _sensing: PawnSensing = $"../../../PawnSensing"

var _ball: BallScriptAnima
var _active: bool = false
var _contact_resolved: bool = false


func set_ball(ball: BallScriptAnima) -> void:
	_ball = ball


func can_start() -> bool:
	return (
		definition != null
		and is_instance_valid(_ball)
		and not _active
	)


func start_action() -> bool:
	if not can_start():
		return false

	_active = true
	_contact_resolved = false
	return true


func is_active() -> bool:
	return _active


func can_resolve_contact() -> bool:
	return _active and not _contact_resolved


func resolve_contact() -> bool:
	if not can_resolve_contact():
		return false

	_contact_resolved = true
	contact_completed.emit(_ball)
	return true


func finish_action() -> void:
	if not _active:
		return

	_active = false
	action_finished.emit()
