extends Node3D

@export_group('Camera')
@export var subject: Node3D
@export var control_script: Node3D # TODO This needs a unique type.
                                   # TODO control_script can use bezier curves or whatever it wants.
@export_subgroup('Camera Settings')
@export var subject_displacement := Vector3(0, 1.0, 0)
# TODO I should turn all these lerp rates into a type that auto-manages the values.
## How quickly the camera's position races to match the position of its subject.
@export var position_lerp_rate_x: float = 24.0
@export var position_lerp_rate_y: float = 6.0
## How quickly the camera's rotation races to face the position of its subject.
@export var rotation_lerp_rate: float = 24.0
## How quickly the camera's pivot rotation races to match its ideal orientation.
@export var pivot_lerp_rate: float = 4.0
@export var pivot_hor_max: float = 8.0
@export var pivot_ver_max: float = 8.0
@export var camera_distance: float = 16.0
@export var free_look_zoom_distance: float = 4.0

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

var ideal_position := Vector3()
var ideal_rotation := Vector3()

@onready var _pivot: Node3D = %Pivot
@onready var _camera_arm: Node3D = %CameraArm
@onready var _camera_head: Node3D = %CameraHead
@onready var _camera: Camera3D = %Camera3D
@onready var _spotlight: SpotLight3D = %SpotLight3D


func _physics_process(delta: float) -> void:
   if not subject:
      return

   # Set camera's desired position.
   ideal_position.x = subject.position.x
   ideal_position.y = subject.position.y + 5.0 # TODO 4.0 for demo only; Remove

   # Lerp camera to ideal position.
   position.x = lerp(position.x, ideal_position.x, position_lerp_rate_x * delta)
   position.y = lerp(position.y, ideal_position.y, position_lerp_rate_y * delta)

   # Set camera's desired rotation.
   var subject_focal_point_displacement := Vector3(0, 2.0, 0)
   var vector_to_subject := subject.global_position - _camera_head.global_position + subject_focal_point_displacement
   var subject_xz_plane := Vector3(vector_to_subject.x, 0, vector_to_subject.z)
   var subject_yz_plane := Vector3(0, vector_to_subject.y, vector_to_subject.z)

   ideal_rotation.y = Vector3.BACK.signed_angle_to(subject_xz_plane, Vector3.UP)
   ideal_rotation.x = Vector3.BACK.signed_angle_to(subject_yz_plane, Vector3.LEFT)

   # Lerp camera to ideal rotation.
   _camera_head.rotation.y = lerp(_camera_head.rotation.y, ideal_rotation.y, rotation_lerp_rate * delta)
   _camera_head.rotation.x = lerp(_camera_head.rotation.x, ideal_rotation.x, rotation_lerp_rate * delta)

   # Allow stick input to affect camera.
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
   var arm_retraction_length := curved_stick_input.length() * free_look_zoom_distance

   # Lerp camera pivot and zoom-in values to ideal settings.
   _pivot.rotation.y = lerp(_pivot.rotation.y, ideal_pivot_rotation.y, pivot_lerp_rate * delta)
   _pivot.rotation.x = lerp(_pivot.rotation.x, ideal_pivot_rotation.x, pivot_lerp_rate * delta)
   _camera_arm.position.z = lerp(_camera_arm.position.z, camera_distance - arm_retraction_length, pivot_lerp_rate * delta)
