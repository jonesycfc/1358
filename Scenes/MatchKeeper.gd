class_name MatchKeeper
extends Node

const MAX_TEAM_TOUCHES: int = 3
const MAX_TEAM_CONTACTS: int = 3

static var team_in_possession: Enums.Team = Enums.Team.Home

static func is_team_in_possession(team: Enums.Team) -> bool:
	return team == team_in_possession

static func get_team_in_possession() -> Enums.Team:
	return team_in_possession

static func set_opp_team_in_possession(current_team: Enums.Team) -> void:
	var next_team := Enums.Team.Away if current_team == Enums.Team.Home else Enums.Team.Home
	set_team_in_possession(next_team)

static var touches_used_by_team: Dictionary = {
	Enums.Team.Home: 0,
	Enums.Team.Away: 0
}


static func get_team_touches_used(team: Enums.Team) -> int:
	return touches_used_by_team.get(team, 0)

static func reset_team_touches(team: Enums.Team) -> void:
	touches_used_by_team[team] = 0


static func set_team_in_possession(new_team: Enums.Team) -> void:
	if team_in_possession != new_team:
		team_in_possession = new_team
		reset_team_touches(new_team)

static func reset_match_state(starting_team: Enums.Team = Enums.Team.Home) -> void:
	team_in_possession = starting_team
	for team in [Enums.Team.Home, Enums.Team.Away]:
		touches_used_by_team[team] = 0

static func register_team_touch(team: Enums.Team) -> bool:
	var used: int = get_team_touches_used(team)

	if used >= MAX_TEAM_CONTACTS:
		return false

	touches_used_by_team[team] = used + 1
	return true
