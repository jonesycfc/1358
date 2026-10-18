class_name ik_test
extends Node

const HAND_BONE: StringName = &"hand_r"

@export var anim1: StringName = &"SpikeTesting1/WeakSpikeFull"
@export var anim2: StringName = &"SpikeTesting1/FullPowerFullSpikeFullAnim"
@export var test_animation: StringName = anim1
@export var test_frame: int = 52
@export var total_frames: int = 96

@onready var _animation_scene: PawnAnimationScene = $"../../PawnAnimationScene"

func test_hand_position() -> void:
	var animation_player := _animation_scene.get_animation_player()
	var animation := animation_player.get_animation(test_animation)

	var frame_time := animation.length / total_frames
	var test_time := test_frame * frame_time

	animation_player.current_animation = test_animation
	animation_player.seek(test_time, true)

	var hand_position := get_hand_world_position()

	print("Contact frame: ", test_frame)
	print("Animation time: ", test_time)
	print("Hand world position: ", hand_position)




func get_hand_world_position() -> Vector3:
	var skeleton := _animation_scene.get_skeleton()

	var bone_index := skeleton.find_bone(HAND_BONE)

	var hand_pose := skeleton.get_bone_global_pose(bone_index)

	return (skeleton.global_transform * hand_pose).origin
