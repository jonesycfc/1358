class_name TitleScreen
extends Control

var _match_config: MatchConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_match_config = MatchConfig.new()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	_match_start()

func _on_home_team_button_pressed() -> void:
	user_change(Enums.Team.Home)

func _on_away_team_button_pressed() -> void:
	user_change(Enums.Team.Away)

func user_change(team: Enums.Team) -> void:
	var button: Button
	var string: String

	if team == Enums.Team.Home:
		button = $HBoxContainer/VBoxContainer/HomeTeamButton
	else:
		button = $HBoxContainer/VBoxContainer2/AwayTeamButton

	if _match_config.update_team_user(team) == Enums.UserType.Human:
		string = "P1"
	else:
		string = "CPU"

	button.text = string
	
func _unhandled_input(event):
	if event.is_action_pressed("Start"):
		_match_start()

func _match_start() ->void:
	var match_scene = HostNode.change_scene("Match")
	HostNode.start_match(match_scene, _match_config)
