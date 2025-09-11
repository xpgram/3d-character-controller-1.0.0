class_name ICameraRigBehavior3D
extends Resource
## An interface for [CameraRig3D] behaviors.


## Whether this behavior should be processed and applied.
var enabled := true


## Updates this behavior's state.
func process(_delta: float) -> void:
   pass


## Returns a set of transform values for this camera behavior representing its current
## state.
func get_rig_transform() -> CameraRigTransform3D:
   return CameraRigTransform3D.new()
