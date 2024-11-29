extends CharacterBody3D
## Handles player character behaviors.

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(-180, 180) var camera_upper_bound_degrees: int = -75
@export_range(-180, 180) var camera_lower_bound_degrees: int = 30

var CAMERA_UPPER_BOUND: float = camera_upper_bound_degrees / 180.0 * PI
var CAMERA_LOWER_BOUND: float = camera_lower_bound_degrees / 180.0 * PI

var _camera_mouse_input_direction := Vector2.ZERO

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Node3D = %Camera3D


func _unhandled_input(event: InputEvent) -> void:
   _capture_input_mouse_motion(event)


func _physics_process(delta: float) -> void:
   _move_camera_by_mouse_motion(delta)
   _move_camera_by_gamepad_stick(delta)
   _constrain_camera_angles_to_limits()


func _capture_input_mouse_motion(event: InputEvent) -> void:
   ## Saves mouse motion event as a vector input to process later.
   var is_camera_motion := (
         event is InputEventMouseMotion
         and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
   )
   if is_camera_motion:
      _camera_mouse_input_direction = event.screen_relative * mouse_sensitivity


func _move_camera_by_mouse_motion(delta: float) -> void:
   ## Uses mouse motion input to move the camera.
   # TODO Invert axis via game settings
   _camera_pivot.rotation.y -= _camera_mouse_input_direction.x * delta
   _camera_pivot.rotation.x += _camera_mouse_input_direction.y * delta

   # Reset the mouse input vector for next frame.
   _camera_mouse_input_direction = Vector2.ZERO


func _move_camera_by_gamepad_stick(delta: float) -> void:
   ## Uses joystick input to move the camera.
   pass

func _constrain_camera_angles_to_limits() -> void:
   ## Constrains the camera's pivot angle to predefined limits.
   _camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, CAMERA_UPPER_BOUND, CAMERA_LOWER_BOUND)
