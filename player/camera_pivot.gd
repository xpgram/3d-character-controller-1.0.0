extends Node3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.15
@export_range(0.0, 1,0) var stick_sensitivity := 0.25
@export_range(-180, 180) var camera_upper_bound_degrees: int = -75
@export_range(-180, 180) var camera_lower_bound_degrees: int = 30

var CAMERA_UPPER_BOUND: float = camera_upper_bound_degrees / 180.0 * PI
var CAMERA_LOWER_BOUND: float = camera_lower_bound_degrees / 180.0 * PI
var CAMERA_STICK_SPEED: float = 12.0

var _camera_mouse_input_direction := Vector2.ZERO

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
   rotation.y -= _camera_mouse_input_direction.x * delta
   rotation.x += _camera_mouse_input_direction.y * delta

   # Reset the mouse input vector for next frame.
   _camera_mouse_input_direction = Vector2.ZERO


func _move_camera_by_gamepad_stick(delta: float) -> void:
   ## Uses joystick input to move the camera.
   var raw_input := Input.get_vector(
      "look_left",
      "look_right",
      "look_up",
      "look_down",
      0.4
   )
   # This step squares the "strength" of the input vector, allowing finer control near the
   # lower end of the range.
   var curved_input := raw_input * raw_input.length()
   var scaled_input := curved_input * CAMERA_STICK_SPEED * stick_sensitivity * delta

   rotation.y -= scaled_input.x
   rotation.x -= scaled_input.y


func _constrain_camera_angles_to_limits() -> void:
   ## Constrains the camera's pivot angle to predefined limits.
   rotation.x = clamp(rotation.x, CAMERA_UPPER_BOUND, CAMERA_LOWER_BOUND)
