class_name CameraRigController3D
extends Node3D
## A controller script to define the behavior of a CameraRig3D.


## The priority this controller script has over other controllers. Higher
## numbers take precedence over lower ones.
@export_range(0, 9, 1, 'or_greater')
var controller_priority := 0


func operate_rig(_delta: float, _camera_rig: CameraRig3D) -> void:
   return
