class_name CameraRigOperatorStack3D
extends Node3D
## A node that listens for 'camera operator change' events and manages the flow of control
## between them.

# TODO Transition types:
#  - Enter transition:
#     Occurs when a region is entered and this operator stack immediately switches to it.
#  - Resume transition:
#     Occurs when a region is exited and a previously entered region resumes control.
#     'Resume' occurs even if this is the first time this region has had control.
#  - Exit transition:
#     Occurs when a region is exited. This happens separately (and before) enter and
#     resume transitions occur.


@export var default_rig_operator: CameraRigOperator3D

var _controllers: Array[CameraRigOperator3D] = []


func _init() -> void:
   Events.camera_region_entered.connect(_on_camera_region_entered)
   Events.camera_region_exited.connect(_on_camera_region_exited)


func _on_camera_region_entered(_target: CameraTarget3D, region: CameraRegion3D):
   _controllers.append(region.camera_controller)


func _on_camera_region_exited(_target: CameraTarget3D, region: CameraRegion3D):
   _controllers.erase(region.camera_controller)


## Sorts the stack of controllers by their own priority values. Maintains first-in-last-
## out relationships between same-priority controllers.
func _resort_controllers() -> void:
   # FIXME This doesn't preserve order among same-priority operators, it seems.
   _controllers.sort_custom(
      func (a: CameraRigOperator3D, b: CameraRigOperator3D):
         return a.controller_priority < b.controller_priority
   )


## Returns the currently in-focus [CameraRigOperator3D] of the stack.
## If there are no operators in the stack, returns the default operator.
func get_current_operator() -> CameraRigOperator3D:
   var current_operator = _controllers.back()
   if current_operator == null:
      current_operator = default_rig_operator
   return current_operator
