extends Node3D

@export_group('Camera')
@export var subject: Node3D
@export var control_script: Node3D # TODO This needs a unique type.
                                   # TODO control_script can use bezier curves or whatever it wants.
@export_subgroup('Camera Settings')
# TODO Assess: When control scripts are added, is this field still useful?
## The displacement from the subject's coordinates of the camera rig's position.
@export var camera_position_displacement := Vector3(0, 5.0, 0)
## The displacement from the subject's coordinates of the camera's focal point (where it
## is looking).
@export var camera_focal_point_displacement := Vector3(0, 2.0, 0)
# TODO I should turn all these lerp rates into a type that auto-manages the values.
## How quickly the camera's position races to match the x-axis position of its subject.
@export var position_lerp_rate_x: float = 24.0
## How quickly the camera's position races to match the y-axis position of its subject.
@export var position_lerp_rate_y: float = 6.0
## How quickly the camera's rotation races to face the position of its subject.
@export var rotation_lerp_rate: float = 24.0
## How quickly the camera's pivot rotation races to match its ideal orientation.
@export var pivot_lerp_rate: float = 4.0
## How far the camera arm extends from the rig's coordinates.
@export var camera_distance: float = 16.0
## How far in degrees the camera arm will rotate horizontally when tilt-looking.
@export var pivot_hor_max: float = 8.0 # TODO Degrees
## How far in degrees the camera arm will rotate vertically when tilt-looking.
@export var pivot_ver_max: float = 8.0
## How far the camera zooms in when the player is tilt-looking.
@export var camera_tilt_zoom_distance: float = 4.0

# TODO I should pop these settings into a singleton node.
@export_group('Control Settings')
@export_subgroup('Mouse and Keyboard')
@export var mouse_sensitivity: float = 0.15
@export var mouse_invert_y: bool = false
@export var mouse_invert_x: bool = false
@export_subgroup('Controller')
@export var stick_sensitivity: float = 0.25
@export var stick_invert_y: bool = false
@export var stick_invert_x: bool = false

## The pivot joint used to rotate the camera arm.
@onready var _pivot: Node3D = %Pivot
## The arm that holds the camera head at a distance from the rig's base coordinates.
@onready var _camera_arm: Node3D = %CameraArm
## A pivot joint used to rotate the camera's lense and related accessories.
@onready var _camera_head: Node3D = %CameraHead
## The camera object that renders the scene.
@onready var _camera_lense: Camera3D = %Camera3D
## The camera's head-mounted light.
@onready var _camera_spotlight: SpotLight3D = %SpotLight3D


func _ready() -> void:
   _teleport_to_position()


## Skips all the animation lerps used in physics processes elsewhere.
func _teleport_to_position() -> void:
   # IMPLEMENT Run the same functions with lerp(x, new_x, 1.0)?
   pass


func _physics_process(delta: float) -> void:
   if not subject:
      return

   _process_camera_rig_position(delta)
   _process_camera_arm_rotation(delta)
   _point_camera_head_at_subject(delta)


# TODO This will be controlled by camera controller scripts, actually.
#   But I should keep this as default behavior, maybe.
## Positions the camera rig over its subject's coordinates.
func _process_camera_rig_position(delta: float) -> void:
   var ideal_position := subject.position + camera_position_displacement
   ideal_position.z = 0.0

   position.x = lerp(position.x, ideal_position.x, position_lerp_rate_x * delta)
   position.y = lerp(position.y, ideal_position.y, position_lerp_rate_y * delta)


## Rotates the camera arm and adjusts arm length according to user input.
func _process_camera_arm_rotation(delta: float) -> void:
   # TODO Get this from some utils/input.gd script.
   var stick_vector = Input.get_vector(
      'look_left',
      'look_right',
      'look_up',
      'look_down',
      0.4
   )
   var curved_stick_input: Vector2 = stick_vector * stick_vector.length()
   var curved_input_length: float = curved_stick_input.length()
   curved_stick_input.x = sign(curved_stick_input.x) * curved_stick_input.x ** 2
   curved_stick_input.y = sign(curved_stick_input.y) * curved_stick_input.y ** 2
   curved_stick_input = curved_stick_input.normalized() * curved_input_length
   curved_stick_input = curved_stick_input.limit_length(1.0)

   var ideal_pivot_rotation := Vector3(
      # TODO Magic numbers.
      -curved_stick_input.y * PI * pivot_ver_max / 100.0,
      -curved_stick_input.x * PI * pivot_hor_max / 100.0,
      0,
   )
   
   _pivot.rotation.y = lerp(_pivot.rotation.y, ideal_pivot_rotation.y, pivot_lerp_rate * delta)
   _pivot.rotation.x = lerp(_pivot.rotation.x, ideal_pivot_rotation.x, pivot_lerp_rate * delta)

   var arm_retraction_length := curved_stick_input.length() * camera_tilt_zoom_distance
   _camera_arm.position.z = lerp(_camera_arm.position.z, camera_distance - arm_retraction_length, pivot_lerp_rate * delta)


## If a subject exists, rotates the camera head such that its visual center is facing the
## sum of the subject's coordinates and the camera_focal_point_displacement vector.
func _point_camera_head_at_subject(delta: float) -> void:
   if not subject:
      return

   var vector_to_subject := subject.global_position - _camera_head.global_position + camera_focal_point_displacement
   var subject_xz_plane := vector_to_subject.slide(Vector3.UP)
   var subject_yz_plane := vector_to_subject.slide(Vector3.LEFT)

   var ideal_rotation := Vector3(
      Vector3.BACK.signed_angle_to(subject_yz_plane, Vector3.LEFT),
      Vector3.BACK.signed_angle_to(subject_xz_plane, Vector3.UP),
      0.0,
   )

   _camera_head.rotation.y = lerp(_camera_head.rotation.y, ideal_rotation.y, rotation_lerp_rate * delta)
   _camera_head.rotation.x = lerp(_camera_head.rotation.x, ideal_rotation.x, rotation_lerp_rate * delta)
