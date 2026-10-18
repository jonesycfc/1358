class_name ActionDelegator
extends Node

@onready var _movement: PawnMovement = $PawnMovement
@onready var _ba: BallActions = $BallActions
@onready var _sprites: PawnSprites = $Sprites
@onready var _pawn: PawnClass = get_parent()
@onready var _orient: PawnOrientation = $PawnOrientation
@onready var _sensing: PawnSensing = $"../PawnSensing"
@onready var _hit_selection: HitSelection = $PawnChoices/HitSelection

var _ball: BallScriptAnima


func tick(delta: float) -> void:
	var ball := _sensing.get_ball()
	if not is_instance_valid(ball):
		_movement.stop()
		_ba.tick(delta)
		return

	_orient.set_target_object(ball)
	var team := MatchKeeper.get_team_in_possession()

	if team == _pawn.get_team():
		var landing := ball.get_landing_position()
		var action := _hit_selection.evaluate_from_match_state(landing)
		var receiver := _hit_selection.get_designated_receiver()

		if action != Enums.HitAction.SUPPORT and action != Enums.HitAction.NONE:
			if not _ba.is_action_active():
				_movement.move_to_ball_landing()
				#print("action delegator, pawn moving: ", _pawn.get_pawn_name())
		elif is_instance_valid(receiver):
			_movement.move_to_support_position(landing, receiver.global_position)
		else:
			_movement.stop()

		_movement.tick(delta)
	else:
		_movement.stop()

	_ba.tick(delta)


func set_ball(ball: BallScriptAnima) -> void:
	_ball = ball
	_ba.set_ball(ball)
	_sensing.set_ball(ball)
	_orient.set_target_object(ball)


func show_impact_sprite(position: Vector3) -> void:
	_sprites.show_impact(position)


func possession_update() -> void:
	# Possession remains with the team during its three contacts.
	# Transfer to the other team only after the final contact.
	var team := _pawn.get_team()
	if MatchKeeper.get_team_touches_used(team) >= MatchKeeper.MAX_TEAM_CONTACTS:
		MatchKeeper.set_opp_team_in_possession(team)
		for node in get_tree().get_nodes_in_group("team_coordinators"):
			if node is TeamCoordinator:
				(node as TeamCoordinator).reset_touch_history()
