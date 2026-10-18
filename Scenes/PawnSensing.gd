class_name PawnSensing
extends Node

@onready var _pawn: PawnClass = get_parent()

var _ball: BallScriptAnima


func set_ball(ball: BallScriptAnima) -> void:
	_ball = ball


func get_ball() -> BallScriptAnima:
	if not is_instance_valid(_ball):
		return null
	return _ball


func get_ball_position_at_time(time: float) -> Vector3:
	var ball := get_ball()
	if ball == null:
		return _pawn.global_position
	return ball.get_position_at_time(time)


func get_ball_landing_position() -> Vector3:
	var ball := get_ball()
	if ball == null:
		return _pawn.global_position
	return ball.get_landing_position()
