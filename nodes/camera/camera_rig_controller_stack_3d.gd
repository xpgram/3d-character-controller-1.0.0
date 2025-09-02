class_name CameraRigControllerStack3D
extends Node3D
## A node that listens for 'camera controller change' events and manages the flow of control
## between them.

# TODO Transition types:
#  - Enter transition:
#     Occurs when a region is entered and this controller stack immediately switches to it.
#  - Resume transition:
#     Occurs when a region is exited and a previously entered region resumes control.
#     'Resume' occurs even if this is the first time this region has had control.
#  - Exit transition:
#     Occurs when a region is exited. This happens separately (and before) enter and
#     resume transitions occur.
# TODO Transition styles:
#  - Lerp
#    - (By default, I think. More importantly, how do I get it to _not_ lerp?)
#  - Special Script that does whatever it wants
#  - Fade out/in
#  - Fade out, wait, signal in


@export var default_rig_controller: CameraRigController3D

var _controllers: Array[CameraRigController3D] = []


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
   # FIXME This doesn't preserve order among same-priority controllers, it seems.
   _controllers.sort_custom(
      func (a: CameraRigController3D, b: CameraRigController3D):
         return a.controller_priority < b.controller_priority
   )


## Returns the currently in-focus [CameraRigController3D] of the stack.
## If there are no controllers in the stack, returns the default controller.
func get_controller() -> CameraRigController3D:
   var controller = _controllers.back()
   if controller == null:
      controller = default_rig_controller
   return controller
