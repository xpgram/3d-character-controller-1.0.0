class_name CameraBehavior_TiltCamera
extends ICameraRigBehavior3D
## A camera behavior to allow players to use their camera input axes to tilt the camera
## along the level track. Assumes some other behavior sets independent camera transform
## values.


const InputUtils = preload('uid://tl2nnbstems3')


## Whether smooth movement animations should be enabled.
@export var enable_animation := true

## Whether to accept user input. With no user input, a vector input of (0,0) is assumed.
@export var enable_input := true

## Whether this behavior should apply itself to a [CameraRig3D] additively, preserving
## other behavior's output, or if false, that it should apply itself absolutely,
## overwriting any previous output.
@export var apply_additively := true

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

## How far the camera normally sits when at minimum tilt.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var max_arm_length := 16.0

## How far the camera zooms in when at max tilt. Zoom distance is proportional to input
## vector length. The input vector is taken from the current input method's camera look
## axes.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var tilt_zoom_retraction_length := 4.0

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
   target_stick_input = InputUtils.get_camera_look_vector() if enable_input else Vector2.ZERO

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

   # Determine additive component of new transforms.
   var additive_pivot_rotation := camera_rig.pivot_rotation if apply_additively else Vector3.ZERO
   var additive_arm_length := camera_rig.arm_length if apply_additively else 0.0

   # Determine this behavior's component of new transforms.
   var new_pivot_rotation := Vector3(
      -actual_stick_input.y * max_tilt_hor,
      -actual_stick_input.x * max_tilt_ver,
      0.0,
   )
   var new_arm_length := max_arm_length - (mix_weight * tilt_zoom_retraction_length)

   # Apply new transforms.
   camera_rig.pivot_rotation = additive_pivot_rotation + new_pivot_rotation
   camera_rig.arm_length = additive_arm_length + new_arm_length
   # Focal point lerping between actual position and rig position is not possible in
   # absolute mode.
   if not apply_additively:
      camera_rig.focal_point = camera_rig.focal_point.lerp(camera_rig.position, mix_weight)

   # Add extra tilt by moving the focal point laterally to the XY plane of the rig.
   var focal_point_displacement := Vector3(
      # TODO Why does .rotated() below require this value be positive?
      #  I'd think because the level is facing the wrong z-direction, but this positive
      #  value works for all rig orientations. I think.
      actual_stick_input.x * max_look_ahead_hor,
      -actual_stick_input.y * max_look_ahead_ver,
      0.0,
   )
   camera_rig.focal_point += focal_point_displacement.rotated(Vector3.UP, camera_rig.rotation.y)
