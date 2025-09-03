class_name CameraRigController3D
extends Node3D
## A controller script to define the behavior of a CameraRig3D.


## The priority this controller script has over other controllers. Higher
## numbers take precedence over lower ones.
@export_range(0, 9, 1, 'or_greater')
var controller_priority := 0

# TODO These transitions need to be processed over time and I'm not actually sure how that
#  is meant to happen yet. It's more likely these controllers will describe a transition
#  they want, and the ControllerStack will actually process it. I'll probably need to
#  write a new CameraTransition resource to handle the phase-in, setup, phase-out process.

## To be run when this controller is given control of a [CameraRig3D] at the same time
## that a [CameraTarget3D] entered this node's parent [CameraRegion3D].
func on_enter_transition(_camera_rig: CameraRig3D) -> void:
   return


## To be run when this controller is given control of a [CameraRig3D] while a
## [CameraTarget3D] is already in contact with this node's parent [CameraRegion3D].
func on_resume_transition(_camera_rig: CameraRig3D) -> void:
   return


## To be run when this controller yields control of a [CameraRig3D] at the same time that
## a [CameraTarget3D] exited this node's parent [CameraRegion3D].
func on_exit_transition(_camera_rig: CameraRig3D) -> void:
   return


## Move and rotate a given [CameraRig3D] into some starting position that this controller
## can then operate it from.
func setup_initial_rig_conditions(_camera_rig: CameraRig3D) -> void:
   return


## Move and rotate a given [CameraRig3D] into a new position. This should typically be
## called in a process step.
func operate_rig(_delta: float, _camera_rig: CameraRig3D) -> void:
   return
