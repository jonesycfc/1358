
class_name HitActionDefinition
extends Resource

enum Kind {
	RECEIVE,
	SET,
	SPIKE,
	BLOCK,
	FREE_BALL
}

enum TargetPolicy {
	TEAMMATE,
	SETTER_ZONE,
	ATTACK_ZONE,
	OPPONENT_COURT
}

@export var display_name: String = "Hit Action"
@export var kind: Kind = Kind.RECEIVE

@export_group("Animation")
@export var animation_name: StringName
@export var animation_fps: float = 60.0
@export var contact_frame: int = 10
@export var contact_offset: Vector3 = Vector3.ZERO
@export var requires_jump: bool = false
@export var takeoff_frame: int = 0
@export var jump_velocity: float = 10.0

@export_group("Contact")
@export var contact_distance: float = 1.0
@export var max_vertical_speed: float = 25.0

@export_group("Trajectory")
@export var target_policy: TargetPolicy = TargetPolicy.TEAMMATE
@export var target_height: float = 2.5
@export var minimum_flight_time: float = 0.6
@export var maximum_flight_time: float = 1.5
@export var preferred_flight_time: float = 1.0
@export var power_multiplier: float = 1.0


func get_contact_time() -> float:
	return float(contact_frame) / maxf(animation_fps, 1.0)


func get_takeoff_time() -> float:
	return float(takeoff_frame) / maxf(animation_fps, 1.0)


func is_valid_definition() -> bool:
	return (
		not animation_name.is_empty()
		and contact_frame >= 0
		and animation_fps > 0.0
		and contact_distance > 0.0
		and minimum_flight_time > 0.0
		and maximum_flight_time >= minimum_flight_time
	)
