class_name ICameraRigBehavior3D
extends Resource
## An interface for [CameraRig3D] behaviors.


## Whether this behavior should be processed and applied.
var enabled := true


# TODO How can I communicate the state surrounding the rig without awkwardly passing in
#  camera state we shouldn't be able to modify from here?
## Updates this behavior's state.
func process(_delta: float, _camera_rig: CameraRig3D) -> void:
   pass


## Returns a set of transform values for this camera behavior representing its current
## state.
func get_rig_transform() -> CameraRigTransform3D:
   return CameraRigTransform3D.new()
