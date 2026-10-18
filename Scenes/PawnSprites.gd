class_name PawnSprites
extends Node

@export_category("Impact")
@export var impact_duration: float = 0.2

@onready var _impact_sprite: Sprite3D = $ImpactSprite


func show_impact(position: Vector3) -> void:
	_impact_sprite.global_position = position
	_impact_sprite.visible = true

	_clear_impact_after_delay()


func _clear_impact_after_delay() -> void:
	await get_tree().create_timer(impact_duration).timeout
	_impact_sprite.visible = false
