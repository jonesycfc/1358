class_name BallProperties
extends Node

@onready var _ball : RigidBody3D = $"../"
@onready var mesh_instance : MeshInstance3D = $"../MeshInstance3D"
@export var size: Vector3 = Vector3.ONE:
	set(value):
		size = value
		_update_children()

func _update_children() -> void:
	for child in _ball.get_children():
		if child is MeshInstance3D:
			_update_mesh_instance()
		elif child is CollisionShape3D:
			_update_collision_shape(child)


func _update_mesh_instance() -> void:

	var mesh: Mesh = mesh_instance.mesh.duplicate()
	mesh_instance.mesh = mesh

	if mesh is BoxMesh:
		mesh.size = size
	elif mesh is SphereMesh:
		mesh.radius = size.x * 0.5
		mesh.height = size.y

func _update_collision_shape(collision: CollisionShape3D) -> void:
	if collision.shape == null:
		return

	var shape: Shape3D = collision.shape.duplicate()
	collision.shape = shape

	if shape is BoxShape3D:
		shape.size = size
	elif shape is SphereShape3D:
		shape.radius = size.x * 0.5
	elif shape is CapsuleShape3D:
		shape.radius = size.x * 0.5
		shape.height = size.y
	elif shape is CylinderShape3D:
		shape.radius = size.x * 0.5
		shape.height = size.y
	else:
		collision.scale = size
