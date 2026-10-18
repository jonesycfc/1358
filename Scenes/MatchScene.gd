class_name MatchScene
extends Node3D

var _match_config: MatchConfig
var _inputs: ControllerInputs

func _ready() -> void:
	_inputs = ControllerInputs.new($MainCamera)
	pass
	
func setup(m_config: MatchConfig):
	_match_config = m_config if m_config != null else MatchConfig.new()
	#if _match_config.team_users[Enums.Team.Home] == Enums.UserType.Human:
		#_inputs.set_team_controlled(Enums.Team.Home)
	$Spawner/Characters.set_match_config(_match_config)
	$Spawner/Characters.spawn_team()
	
	PawnNetwork.move_team_to_formation(Enums.Team.Home)
	PawnNetwork.move_team_to_formation(Enums.Team.Away)
	
func _process(delta: float) -> void:
	_inputs.tick(delta)

#func _unhandled_input(event):
	#if event.is_action_pressed("X"):
		#var ball := $Spawner/Ball.spawn()
		#var teams: Array[Enums.Team] = [Enums.Team.Home, Enums.Team.Away]
		#for team in teams:
			#for pawn in $Spawner/Characters.get_pawns_by_team(team):
				#pawn.set_ball(ball)
				#pawn.locomotion.face_target = ball
		#
