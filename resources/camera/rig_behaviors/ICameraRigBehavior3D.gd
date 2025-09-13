class_name ICameraRigBehavior3D
extends Resource
## An interface for [CameraRig3D] behaviors.


## Whether this behavior should be processed and applied.
@export var enabled := true


## Setup initial conditions for this behavior.
## `param camera_rig` A reference to the [CameraRig3D] being operated.
##   By convention, this should be modified additively to preserve changes made by other
##   behaviors. However, this format does allow overriding behavior as necessary.
func reset_behavior(_camera_rig: CameraRig3D) -> void:
   pass


## Processes behavior state and modifies a given [CameraRig3D].
## `param delta` The time since last frame.
## `param camera_rig` A reference to the [CameraRig3D] being operated.
##   By convention, this should be modified additively to preserve changes made by other
##   behaviors. However, this format does allow overriding behavior as necessary.
func update_camera_rig(_delta: float, _camera_rig: CameraRig3D) -> void:
   pass


## For behaviors that animate their values to some intended state, skip the animation and
## assume the intended state immediately.
func skip_animation() -> void:
   pass
