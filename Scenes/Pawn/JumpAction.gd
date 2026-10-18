class_name JumpAction
extends Node


enum State {
	IDLE,
	PREJUMP,
	LEAP,
	ATTACK_OPEN,
	PRE_LAND_TRANSITION,
	PRE_LAND,
	LAND
}


enum JumpType {
	HIGH,
	LOW
}


const HIGH_PREJUMP_ANIM := &"SpikeTesting1/FullLift"
const HIGH_LEAP_ANIM := &"SpikeTesting1/FullLeap"
const HIGH_ATTACK_OPEN_LOOP_ANIM := &"SpikeTesting1/SpikeFalling"
const HIGH_ATTACK_TO_PRELAND_ANIM := &"SpikeTesting1/AttackToPreLand"
const HIGH_PRELAND_LOOP_ANIM := &"SpikeTesting1/PreLand"
const HIGH_LAND_ANIM := &"SpikeTesting1/FullPowerLand"

const LOW_PREJUMP_ANIM := &""
const LOW_LEAP_ANIM := &""
const LOW_ATTACK_OPEN_LOOP_ANIM := &""
const LOW_ATTACK_TO_PRELAND_ANIM := &""
const LOW_PRELAND_LOOP_ANIM := &""
const LOW_LAND_ANIM := &""

const HIGH_AIR_ATTACK_OPEN_TIME := 0.05
const LOW_AIR_ATTACK_OPEN_TIME := 0.20

# This is the point at which the attack window closes.
# The animation then transitions from the attack-open loop
# into the landing-compatible loop.
const HIGH_AIR_ATTACK_CLOSE_TIME := 0.15
const LOW_AIR_ATTACK_CLOSE_TIME := 0.50


var _gravity: float = 20.0
@export var _jump_velocity: float = 15.0
var _forward_velocity: float = 0.0

var _can_air_attack := false
var _state := State.IDLE
var _jump_type := JumpType.HIGH


@onready var _pawn: PawnClass = $"../.."
@onready var _pawn_animation: PawnAnimationScene = $"../../PawnAnimationScene"


func _ready() -> void:
	_pawn_animation.animation_finished.connect(_on_animation_finished)


func physics_update(delta: float) -> void:
	match _state:
		State.LEAP:
			_update_leap(delta)

		State.ATTACK_OPEN:
			_update_attack_open(delta)
			_pawn.position

		State.PRE_LAND_TRANSITION, State.PRE_LAND:
			_update_airborne(delta)

		_:
			_update_grounded_physics(delta)


func physics_post_update() -> void:
	match _state:
		State.PRE_LAND:
			if _pawn.is_on_floor():
				_begin_land()


func _update_leap(delta: float) -> void:
	_apply_gravity(delta)

	if _pawn.velocity.y <= 0.0:
		_begin_attack_open()


func _update_attack_open(delta: float) -> void:
	_apply_gravity(delta)

	_update_air_attack_window()

	if _has_air_attack_window_closed():
		_begin_pre_land_transition()


func _update_airborne(delta: float) -> void:
	_apply_gravity(delta)


func _update_grounded_physics(delta: float) -> void:
	if not _pawn.is_on_floor():
		_apply_gravity(delta)
	elif _pawn.velocity.y < 0.0:
		_pawn.velocity.y = 0.0


func _apply_gravity(delta: float) -> void:
	pass
	#_pawn.velocity.y -= _gravity * delta


func _update_air_attack_window() -> void:
	if _can_air_attack:
		return

	if _pawn_animation.get_animation_position() >= _get_air_attack_open_time():
		_can_air_attack = true


func _has_air_attack_window_closed() -> bool:
	return _pawn_animation.get_animation_position() >= _get_air_attack_close_time()


func _get_air_attack_open_time() -> float:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_AIR_ATTACK_OPEN_TIME

		JumpType.LOW:
			return LOW_AIR_ATTACK_OPEN_TIME

	return 0.0


func _get_air_attack_close_time() -> float:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_AIR_ATTACK_CLOSE_TIME

		JumpType.LOW:
			return LOW_AIR_ATTACK_CLOSE_TIME

	return 0.0


func jump() -> void:
	if _state != State.IDLE:
		return

	if not _pawn.is_on_floor():
		return

	_begin_jump(JumpType.HIGH)


func _begin_jump(jump_type: JumpType) -> void:
	_jump_type = jump_type
	_can_air_attack = false
	_state = State.PREJUMP

	_pawn.velocity.x = 0.0
	_pawn.velocity.z = 0.0
	_pawn.velocity.y = 0.0

	_pawn_animation.play_anim(_get_prejump_animation())


func _begin_leap() -> void:
	_state = State.LEAP

	var forward := -_pawn.global_transform.basis.z

	_pawn.velocity.x = forward.x * _forward_velocity
	_pawn.velocity.z = forward.z * _forward_velocity
	_pawn.velocity.y = _jump_velocity

	var airtime := (2.0 * _jump_velocity) / _gravity
	var speed_scale := 1.0 / airtime

	_pawn_animation.play_anim(
		_get_leap_animation(),
		speed_scale
	)


func _begin_attack_open() -> void:
	_state = State.ATTACK_OPEN
	_can_air_attack = false

	_pawn_animation.play_anim(_get_attack_open_animation())


func _begin_pre_land_transition() -> void:
	print("window closed")
	_state = State.PRE_LAND_TRANSITION
	_can_air_attack = false

	_pawn_animation.play_anim(_get_attack_to_preland_animation())


func _begin_pre_land() -> void:
	_state = State.PRE_LAND

	_pawn_animation.play_anim(_get_preland_animation())


func _begin_land() -> void:
	_state = State.LAND

	_pawn_animation.play_anim(_get_land_animation())


func _finish_jump() -> void:
	_state = State.IDLE


func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		HIGH_PREJUMP_ANIM, LOW_PREJUMP_ANIM:
			_begin_leap()

		HIGH_ATTACK_TO_PRELAND_ANIM, LOW_ATTACK_TO_PRELAND_ANIM:
			_begin_pre_land()

		HIGH_LAND_ANIM, LOW_LAND_ANIM:
			_finish_jump()

func _get_prejump_animation() -> StringName:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_PREJUMP_ANIM

		JumpType.LOW:
			return LOW_PREJUMP_ANIM

	return &""


func _get_leap_animation() -> StringName:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_LEAP_ANIM

		JumpType.LOW:
			return LOW_LEAP_ANIM

	return &""


func _get_attack_open_animation() -> StringName:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_ATTACK_OPEN_LOOP_ANIM

		JumpType.LOW:
			return LOW_ATTACK_OPEN_LOOP_ANIM

	return &""


func _get_attack_to_preland_animation() -> StringName:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_ATTACK_TO_PRELAND_ANIM

		JumpType.LOW:
			return LOW_ATTACK_TO_PRELAND_ANIM

	return &""


func _get_preland_animation() -> StringName:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_PRELAND_LOOP_ANIM

		JumpType.LOW:
			return LOW_PRELAND_LOOP_ANIM

	return &""


func _get_land_animation() -> StringName:
	match _jump_type:
		JumpType.HIGH:
			return HIGH_LAND_ANIM

		JumpType.LOW:
			return LOW_LAND_ANIM

	return &""
