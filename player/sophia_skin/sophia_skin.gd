class_name SophiaSkin extends Node3D

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path : String = "parameters/StateMachine/Move/tilt/add_amount"

var run_tilt = 0.0 : set = _set_run_tilt

@export var blink = true : set = set_blink
@onready var blink_timer = %BlinkTimer
@onready var closed_eyes_timer = %ClosedEyesTimer
@onready var eye_mat = $sophia/rig/Skeleton3D/Sophia.get("surface_material_override/2")

func _ready():
	blink_timer.connect("timeout", func():
		eye_mat.set("uv1_offset", Vector3(0.0, 0.5, 0.0))
		closed_eyes_timer.start(0.2)
		)
		
	closed_eyes_timer.connect("timeout", func():
		eye_mat.set("uv1_offset", Vector3.ZERO)
		blink_timer.start(randf_range(1.0, 4.0))
		)

func set_blink(state : bool):
	if blink == state: return
	blink = state
	if blink:
		blink_timer.start(0.2)
	else:
		blink_timer.stop()
		closed_eyes_timer.stop()

func _set_run_tilt(value : float):
	run_tilt = clamp(value, -1.0, 1.0)
	animation_tree.set(move_tilt_path, run_tilt)

func idle():
	state_machine.travel("Idle")
	_make_full_size()

func move():
	state_machine.travel("Move")
	# TODO Adjust animation speed by movement speed
	_make_full_size()

func fall():
	state_machine.travel("Fall")
	_make_full_size()

func jump():
	state_machine.travel("Jump")
	_make_full_size()

func crouch():
	state_machine.travel("Idle")
	_make_half_size()

func crawl():
	state_machine.travel("Move")
	_make_half_size()

func edge_grab():
	state_machine.travel("EdgeGrab")
	_make_full_size()

func wall_slide():
	state_machine.travel("WallSlide")
	_make_full_size()

# TODO Quick and dirty crouching.
#   These functions aren't necessary with an actual "Crouch" animation.
func _make_half_size():
	scale.y = 0.65

func _make_full_size():
	scale.y = 1.0
