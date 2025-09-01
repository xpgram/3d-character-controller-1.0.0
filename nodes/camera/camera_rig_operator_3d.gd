class_name CameraRigOperator3D
extends Node
## A controller script to define the behavior of a CameraRig3D.


## The priority this controller script has over other controllers. Higher
## numbers take precedence over lower ones.
@export_range(0, 9, 1)
var controller_priority := 0

## The subject of camera focus. Most scripts will orient their perspective
## around this object, but this isn't guaranteed.
@export
var subject: Node3D


func operate_rig(_delta: float, _camera_rig: CameraRig3D) -> void:
   pass
   # TODO Implement default camera_rig follow behavior.
   # TODO Also, factor out a bunch of common camera_rig behaviors, like pointing at the subject.
   # TODO Also, factor out the lerp-to-ideal behavior with customizable speed and such.
