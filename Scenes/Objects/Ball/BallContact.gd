class_name BallContact
extends Node

@onready var _ball : RigidBody3D = $"../"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_hit(impulse: Vector3, hit_position: Vector3) -> void:
	_ball.apply_impulse(impulse, hit_position - _ball.global_position)
