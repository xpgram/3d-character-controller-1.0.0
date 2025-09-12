class_name CameraBehavior_SnapFocalToSubject
extends ICameraRigBehavior3D
## A camera behavior to snap the camera's focal point to its subject's position.


## The vector displacement of the focal point from the subject's raw coordinates.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var displacement_from_subject := Vector3.ZERO

## The transform for this behavior.
var _rig_transform := CameraRigTransform3D.new()


func process(_delta: float, camera_rig: CameraRig3D) -> void:
   if not camera_rig.subject:
      return

   _rig_transform.focal_point = camera_rig.subject.global_position + displacement_from_subject


func get_rig_transform() -> CameraRigTransform3D:
   return _rig_transform
