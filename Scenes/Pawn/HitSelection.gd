class_name HitSelection
extends Node

signal action_selected(action: Enums.HitAction)


@export var receive_distance: float = 1.5
@export var attack_distance_from_net: float = 3.0

@onready var _pawn: PawnClass = $"../../.."
@onready var _sensing: PawnSensing = $"../../../PawnSensing"

var _coordinator: TeamCoordinator
var current_action: Enums.HitAction = Enums.HitAction.NONE

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("team_coordinators"):
		if node is TeamCoordinator and node.team == _pawn.get_team():
			_coordinator = node
			break

	if _coordinator:
		_coordinator.register_pawn(_pawn)
	else:
		push_warning("No TeamCoordinator found for pawn: " + _pawn.get_pawn_name())


## Call this when the ball's trajectory has been evaluated.
## predicted_landing should be the ball's projected landing position.
## touches_used is the number of contacts already made this rally
## by the pawn's team.
func evaluate_action(
	ball_position: Vector3,
	predicted_landing: Vector3,
	touches_used: int,
	opponent_attacking: bool = false,
	can_attack: bool = true
) -> Enums.HitAction:

	# Blocking takes priority when an opponent is attacking.
	if opponent_attacking:
		return _select(Enums.HitAction.BLOCK)

	# Only the coordinator-designated teammate should commit to the ball.
	# A missing coordinator should not silently make every pawn a receiver.
	if not is_instance_valid(_coordinator):
		return _select(Enums.HitAction.SUPPORT)

	var receiver := _coordinator.assign_receiver(predicted_landing)
	if receiver != _pawn:
		return _select(Enums.HitAction.SUPPORT)

	match touches_used:
		0:
			return _select(Enums.HitAction.RECEIVE)
		1:
			return _select(Enums.HitAction.SET)
		2:
			if can_attack:
				return _select(Enums.HitAction.ATTACK)
			return _select(Enums.HitAction.FREE_BALL)
		_:
			# Avoid making another contact after the limit.
			return _select(Enums.HitAction.NONE)


func _is_best_receiver(
	predicted_landing: Vector3
) -> bool:
	var my_distance := _horizontal_distance(
		_pawn.global_position,
		predicted_landing
	)

	for node in get_tree().get_nodes_in_group("pawns"):
		if node == _pawn or not is_instance_valid(node):
			continue

		if not node is PawnClass:
			continue

		var teammate := node as PawnClass

		if teammate.get_team() != _pawn.get_team():
			continue

		var teammate_distance := _horizontal_distance(
			teammate.global_position,
			predicted_landing
		)

		# A small margin avoids unnecessary changes in receiver
		# when teammates are almost equally positioned.
		if teammate_distance < my_distance - 0.15:
			return false

	return true


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	var a_flat := Vector2(a.x, a.z)
	var b_flat := Vector2(b.x, b.z)
	return a_flat.distance_to(b_flat)


func _select(action: Enums.HitAction) -> Enums.HitAction:
	if current_action != action:
		current_action = action
		action_selected.emit(action)

	return action

func reset_selection() -> void:
	current_action = Enums.HitAction.NONE

func evaluate_from_match_state(
	predicted_landing: Vector3,
	opponent_attacking: bool = false,
	can_attack: bool = true
) -> Enums.HitAction:
	var touches := MatchKeeper.get_team_touches_used(_pawn.get_team())
	var ball_position := _pawn.global_position
	if is_instance_valid(_sensing.get_ball()):
		ball_position = _sensing.get_ball().global_position

	return evaluate_action(
		ball_position,
		predicted_landing,
		touches,
		opponent_attacking,
		can_attack
	)
func _exit_tree() -> void:
	if is_instance_valid(_coordinator):
		_coordinator.unregister_pawn(_pawn)


func notify_contact() -> void:
	if is_instance_valid(_coordinator):
		_coordinator.note_touch(_pawn)


func get_designated_receiver() -> PawnClass:
	if not is_instance_valid(_coordinator):
		return null
	return _coordinator.get_receiver()
