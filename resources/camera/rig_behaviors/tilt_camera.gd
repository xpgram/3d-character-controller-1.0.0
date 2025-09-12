class_name CameraBehavior_TiltCamera
extends ICameraRigBehavior3D
## A camera behavior to allow players to use their camera input axes to tilt the camera
## along the level track.


const InputUtils = preload('uid://tl2nnbstems3')

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

## The transform for this behavior.
var _rig_transform := CameraRigTransform3D.new()


func process(_delta: float, camera_rig: CameraRig3D) -> void:
   var stick_input := InputUtils.get_camera_look_vector()

   # Tilt the pivot arm.
   _rig_transform.pivot_rotation = Vector3(
      -stick_input.y * max_tilt_hor,
      -stick_input.x * max_tilt_ver,
      0.0,
   )
   # FIXME The lerp for this behavior is in camera_settings under pivot_rotation, and it
   #  can't be overridden individually. Hm...
   #  Behaviors and rig controllers should probably handle their own lerps, but... how do
   #  I unify these settings under a couple defaults, then?

   # Retract arm while tilting.
   _rig_transform.arm_length = stick_input.length() * tilt_zoom_distance

   # FIXME Snap focal point to subject should probably be a seperate behavior.
   # Move the focal point to some distance between the subject and camera position.
   _rig_transform.focal_point = camera_rig.subject.position.lerp(camera_rig.position, stick_input.length())

   # Add extra tilt by moving the focal point laterally to the XY plane of the rig.
   var focal_point_displacement := Vector3(
      -stick_input.x * max_look_ahead_hor,
      -stick_input.y * max_look_ahead_ver,
      0.0,
   )
   _rig_transform.focal_point += focal_point_displacement.rotated(Vector3.UP, camera_rig.rotation.y)


func get_rig_transform() -> CameraRigTransform3D:
   return _rig_transform
