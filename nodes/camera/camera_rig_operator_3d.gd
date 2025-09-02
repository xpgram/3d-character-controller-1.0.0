class_name CameraRigOperator3D
extends Node3D
## A controller script to define the behavior of a CameraRig3D.


## The priority this controller script has over other controllers. Higher
## numbers take precedence over lower ones.
@export_range(0, 9, 1)
var controller_priority := 0

## The subject of camera focus. Most scripts will orient their perspective
## around this object, but this isn't guaranteed.
@export
var subject: Node3D


func get_camera_position(_delta: float, _camera_rig: CameraRig3D) -> Vector3:
   return Vector3.ZERO
   # TODO Implement default camera_rig follow behavior.
   # TODO Also, factor out a bunch of common camera_rig behaviors, like pointing at the subject.
   # TODO Also, factor out the lerp-to-ideal behavior with customizable speed and such.


func get_camera_pivot_rotation(_delta: float, _camera_rig: CameraRig3D) -> void:
   pass


func get_camera_arm_length(_delta: float, _camera_rig: CameraRig3D) -> float:
   return 16.0


func get_camera_settings(_delta: float, _camera_rig: CameraRig3D) -> void:
   pass
   # For controlling FOV and such.
