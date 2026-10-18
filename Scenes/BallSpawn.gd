class_name BallSpawn
extends Node3D

const BALL = preload("res://Scenes/Objects/Ball/BallScript.tscn")
const BALL_START := Vector3(-8.0, 20.0, -3.0)

var ball: BallScriptAnima

func spawn() -> BallScriptAnima:
	if is_instance_valid(ball):
		ball.queue_free()
	ball = BALL.instantiate() as BallScriptAnima
	add_child(ball)
	ball.global_position = BALL_START
	return ball
