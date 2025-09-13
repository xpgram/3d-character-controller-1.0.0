class_name CameraBehavior_TiltCamera
extends ICameraRigBehavior3D
## A camera behavior to allow players to use their camera input axes to tilt the camera
## along the level track. Assumes some other behavior sets independent camera transform
## values.


const InputUtils = preload('uid://tl2nnbstems3')


## Whether smooth movement animations should be enabled.
@export var enable_animation := true

## How far in degrees the camera's pivot arm tilts horizontally.
@export_custom(PROPERTY_HINT_NONE, 'radians, suffix:°')
var max_tilt_hor := PI / 12

## How far in degrees the camera's pivot arm tilts vertically.
@export_custom(PROPERTY_HINT_NONE, 'radians, suffix:°')
var max_tilt_ver := PI / 12

## How far horizontally the focal point moves away from the subject in the direction of
## the camera tilt.
@export_custom(PROPERTY_HINT_LINK, 'suffix:m')
var max_look_ahead_hor := 4.0

## How far vertically the focal point moves away from the subject in the direction of
## the camera tilt.
@export_custom(PROPERTY_HINT_LINK, 'suffix:m')
var max_look_ahead_ver := 2.0

## How far the camera zooms in when at max tilt. Zoom distance is proportional to input
## vector length. The input vector is taken from the current input method's camera look
## axes.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var tilt_zoom_distance := 4.0

## A proportion of delta time. Represents the speed at which this behavior lerps to its
## desired state.
@export_custom(PROPERTY_HINT_NONE, 'suffix:∝s')
var lerp_rate := 1.0


## A point representing the effective input of the camera_look axes.
var actual_stick_input := Vector2.ZERO
var target_stick_input := Vector2.ZERO


func reset_behavior(_camera_rig: CameraRig3D) -> void:
   actual_stick_input = Vector2.ZERO
   target_stick_input = Vector2.ZERO


func update_camera_rig(delta: float, camera_rig: CameraRig3D) -> void:
   target_stick_input = InputUtils.get_camera_look_vector()

   if enable_animation:
      _lerp_values(delta)
   else:
      skip_animation()

   _apply_state_to_rig(camera_rig)


func skip_animation() -> void:
   actual_stick_input = target_stick_input


## Animate actual values toward target values.
func _lerp_values(delta: float) -> void:
   actual_stick_input.x = lerp_angle(actual_stick_input.x, target_stick_input.x, lerp_rate * delta)
   actual_stick_input.y = lerp_angle(actual_stick_input.y, target_stick_input.y, lerp_rate * delta)


## Applies this behavior's state to a [CameraRig3D].
func _apply_state_to_rig(camera_rig: CameraRig3D) -> void:
   var mix_weight = clampf(actual_stick_input.length(), 0, 1)

   camera_rig.pivot_rotation += Vector3(
      -actual_stick_input.y * max_tilt_hor,
      -actual_stick_input.x * max_tilt_ver,
      0.0
   )
   camera_rig.arm_length -= mix_weight * tilt_zoom_distance
   camera_rig.focal_point = camera_rig.focal_point.lerp(camera_rig.position, mix_weight)

   # Add extra tilt by moving the focal point laterally to the XY plane of the rig.
   var focal_point_displacement := Vector3(
      -actual_stick_input.x * max_look_ahead_hor,
      -actual_stick_input.y * max_look_ahead_ver,
      0.0,
   )
   camera_rig.focal_point += focal_point_displacement.rotated(Vector3.UP, camera_rig.rotation.y)
