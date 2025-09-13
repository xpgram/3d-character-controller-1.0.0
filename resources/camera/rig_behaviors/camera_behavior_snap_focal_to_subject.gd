class_name CameraBehavior_SnapFocalToSubject
extends ICameraRigBehavior3D
## A camera behavior to snap the camera's focal point to its subject's position.
## If no subject exists, no focal point adjustments will occur.


## If true, the focal point will snap to its new position instead of being animated toward
## it.
@export var disable_animation := false

## The vector displacement of the focal point from the subject's raw coordinates.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var displacement_from_subject := Vector3.ZERO

## A proportion of delta time. Represents the speed at which the focal point follows the
## camera rig subject over the ground plane.
## Due to how the lerp animation is implemented, this always follows an ease-in curve.
@export_custom(PROPERTY_HINT_NONE, 'suffix:∝s')
var lerp_rate_ground_plane := 1.0

## A proportion of delta time. Represents the speed at which the focal point follows the
## camera rig subject along the vertical axis.
## Due to how the lerp animation is implemented, this always follows an ease-in curve.
@export_custom(PROPERTY_HINT_NONE, 'suffix:∝s')
var lerp_rate_vertical := 1.0

## A point representing the current focal point position for this behavior.
var actual_focal_point := Vector3()

## A point representing the desired focal point position for this behavior.
var intended_focal_point := Vector3()


func reset_behavior(camera_rig: CameraRig3D) -> void:
   if not camera_rig.subject:
      return

   intended_focal_point = _get_focal_point(camera_rig)
   skip_animation()


func update_camera_rig(delta: float, camera_rig: CameraRig3D) -> void:
   if not camera_rig.subject:
      return

   intended_focal_point = _get_focal_point(camera_rig)

   if disable_animation:
      skip_animation()
   else:
      _lerp_actual_to_intended(delta)

   _apply_state_to_rig(camera_rig)


func skip_animation() -> void:
   actual_focal_point = intended_focal_point


## Given a [CameraRig3D], return a [Vector3] representing where the next focal point
## should be.
func _get_focal_point(camera_rig: CameraRig3D) -> Vector3:
   if camera_rig.subject:
      return camera_rig.subject.global_position + displacement_from_subject

   return intended_focal_point


## Animate this behavior's actual_focal_point to its intended_focal_point.
func _lerp_actual_to_intended(delta: float) -> void:
   var actual_ground_point := Vector2(actual_focal_point.x, actual_focal_point.z)
   var intended_ground_point := Vector2(intended_focal_point.x, intended_focal_point.z)
   actual_ground_point = actual_ground_point.lerp(intended_ground_point, lerp_rate_ground_plane * delta)

   var actual_height := lerpf(actual_focal_point.y, intended_focal_point.y, lerp_rate_vertical * delta)

   actual_focal_point = Vector3(
      actual_ground_point.x,
      actual_height,
      actual_ground_point.y,
   )


## Applies this behavior's state to a [CameraRig3D].
func _apply_state_to_rig(camera_rig: CameraRig3D) -> void:
   camera_rig.focal_point = actual_focal_point
