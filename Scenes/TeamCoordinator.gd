class_name TeamCoordinator
extends Node

@export var team: Enums.Team
@export var receiver_switch_margin: float = 0.75

var _teammates: Array[PawnClass] = []
var _receiver: PawnClass
var _last_toucher: PawnClass


func register_pawn(pawn: PawnClass) -> void:
	if pawn.get_team() != team:
		return

	if not _teammates.has(pawn):
		_teammates.append(pawn)


func unregister_pawn(pawn: PawnClass) -> void:
	_teammates.erase(pawn)

	if _receiver == pawn:
		_receiver = null
	if _last_toucher == pawn:
		_last_toucher = null


func get_teammates() -> Array[PawnClass]:
	_prune_teammates()
	return _teammates.duplicate()


func get_receiver() -> PawnClass:
	if is_instance_valid(_receiver):
		return _receiver
	return null


## Called after a successful ball contact. The player who just touched
## the ball is not eligible to receive the immediate next touch if a
## teammate is available.
func note_touch(pawn: PawnClass) -> void:
	if not is_instance_valid(pawn) or pawn.get_team() != team:
		return
	_last_toucher = pawn
	_receiver = null


## Clear touch history when the rally changes to the opposing team.
func reset_touch_history() -> void:
	_last_toucher = null
	_receiver = null


func assign_receiver(landing_position: Vector3) -> PawnClass:
	_prune_teammates()

	if _teammates.is_empty():
		_receiver = null
		return null

	var candidates: Array[PawnClass] = []
	for pawn in _teammates:
		if is_instance_valid(_last_toucher) and pawn == _last_toucher:
			continue
		candidates.append(pawn)

	# Do not let a pawn immediately select itself after touching the ball.
	# If no teammate is available, there is no eligible receiver.
	if candidates.is_empty():
		_receiver = null
		return null

	var best_pawn: PawnClass = null
	var best_distance := INF

	for pawn in candidates:
		var distance := _horizontal_distance(
			pawn.global_position,
			landing_position
		)
		if distance < best_distance:
			best_distance = distance
			best_pawn = pawn

	if not is_instance_valid(_receiver) or not candidates.has(_receiver):
		_receiver = best_pawn
	else:
		var current_distance := _horizontal_distance(
			_receiver.global_position,
			landing_position
		)
		if best_pawn != _receiver \
		and best_distance + receiver_switch_margin < current_distance:
			_receiver = best_pawn

	return _receiver


func is_receiver(pawn: PawnClass) -> bool:
	return is_instance_valid(_receiver) and _receiver == pawn


func _prune_teammates() -> void:
	_teammates = _teammates.filter(
		func(pawn: PawnClass) -> bool:
			return (
				is_instance_valid(pawn)
				and pawn.is_inside_tree()
				and pawn.get_team() == team
			)
	)

	if is_instance_valid(_receiver) and not _teammates.has(_receiver):
		_receiver = null
	if is_instance_valid(_last_toucher) and not _teammates.has(_last_toucher):
		_last_toucher = null


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
