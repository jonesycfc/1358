class_name AnimationFlow
extends Node

@onready var _spike: ShortSpike = $"../ActionDelegator/BallActions/HitActionBase/SpikeAction"
@onready var _jump_action: JumpAction = $JumpAction

@onready var animation_actions: AnimationActions = $AnimationActions
@onready var animation_locomotion: AnimationLocomotion = $AnimationLocomotion
@onready var ik: ik_test = $IK_Test


func play_action(action: AnimationsList) -> void:
	animation_actions.play_action(action)

func short_spike() -> void:
	_spike.jump()

func jump() -> void:
	_jump_action.jump()

func iktest() -> void:
	ik.test_hand_position()
