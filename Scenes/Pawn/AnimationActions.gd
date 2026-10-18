class_name AnimationActions
extends Node

@onready var _pawn_base: PawnAnimationScene = $"../../PawnAnimationScene"
@onready var _pawn: PawnClass = $"../.."

var _action: AnimationsList
var _section_index: int = -1

var _movement_profile: SectionProfile
var _movement_active: bool = false
var _movement_start_transform: Transform3D


func _ready() -> void:
	_pawn_base.animation_finished.connect(
		_on_animation_finished
	)

func _physics_process(_delta: float) -> void:
	pass

func play_action(action: AnimationsList) -> void:
	_action = action
	_section_index = -1

	_play_next_section()


func _play_next_section() -> void:
	_section_index += 1

	if _section_index >= _action.sections.size():
		_finish_action()
		return

	var section: AnimationSection = _action.sections[_section_index]

	_pawn_base.play_anim(section.animation)

	if section.movement_profile:
		start_movement(section.movement_profile)
	else:
		_movement_active = false


func _on_animation_finished(anim_name: StringName) -> void:
	if _action == null:
		return

	var section: AnimationSection = _action.sections[_section_index]

	if anim_name != section.animation:
		return

	_play_next_section()


func start_movement(profile: SectionProfile) -> void:
	_movement_profile = profile
	_movement_start_transform = _pawn.global_transform
	_movement_active = true


#func _update_movement() -> void:
	#var animation_player: AnimationPlayer = (
		#_pawn_base.get_animation_player()
	#)
#
	#var current_animation: StringName = (
		#animation_player.current_animation
	#)
#
	#if current_animation.is_empty():
		#return
#
	#var animation_length: float = (
		#animation_player.current_animation_length
	#)
#
	#if animation_length <= 0.0:
		#return
#
	#var current_time: float = (
		#animation_player.current_animation_position
	#)
#
	#var normalized_time: float = (
		#current_time / animation_length
	#)
#
	#var offset: Vector3 = _movement_profile.evaluate(
		#normalized_time
	#)
#
	#var world_offset: Vector3 = (
		#_movement_start_transform.basis * offset
	#)
#
	#_pawn.global_position = (
		#_movement_start_transform.origin
		#+ world_offset
	#)

func _finish_action() -> void:
	_movement_active = false
	_movement_profile = null
	_action = null
	_section_index = -1

func is_action_active() -> bool:
	return _action != null
