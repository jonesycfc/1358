class_name PawnMovement
extends Node

@export var move_speed: float = 5.0

@onready var _pawn: PawnClass = $"../../"
@onready var _sensing: PawnSensing = $"../../PawnSensing"

var target_position: Vector3
var has_target: bool = false


func tick(_delta: float) -> void:
	if not has_target:
		return

	var direction := target_position - _pawn.global_position
	direction.y = 0.0

	if direction.length_squared() < 0.05:
		stop()
		return

	direction = direction.normalized()

	_pawn.velocity.x = direction.x * move_speed
	_pawn.velocity.z = direction.z * move_speed


func move_to_ball_landing() -> void:
	var ball: BallScriptAnima = _sensing.get_ball()
	if not is_instance_valid(ball):
		return

	var landing: Vector3 = ball.get_landing_position()

	target_position = landing
	has_target = true


func move_to_position(position: Vector3) -> void:
	target_position = position
	has_target = true


func stop() -> void:
	has_target = false
	_pawn.velocity.x = 0.0
	_pawn.velocity.z = 0.0
	


func move_to_support_position(landing: Vector3, receiver_position: Vector3) -> void:
	# Keep support players near the play without stacking them on the receiver.
	var away_from_receiver := _pawn.global_position - receiver_position
	away_from_receiver.y = 0.0
	if away_from_receiver.length_squared() < 0.01:
		away_from_receiver = Vector3.RIGHT
	else:
		away_from_receiver = away_from_receiver.normalized()
	var support_target := landing + away_from_receiver * 2.5
	support_target.y = 0.0
	move_to_position(support_target)
