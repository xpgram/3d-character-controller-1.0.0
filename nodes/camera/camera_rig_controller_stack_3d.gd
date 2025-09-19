@tool
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


## A dummy controller which just implements the interface.
var _default_rig_controller: CameraRigController3D = CameraRigController3D.new()

## The list of controllers in the queue.
var _controllers: Array[CameraRigController3D] = []

## (NULLABLE) The last known active camera controller. Used to determine whether on_enter
## or on_resume methods should fire.
var _last_chosen_controller: CameraRigController3D = _default_rig_controller

## A reference to the child [CameraRig3D] being controlled.
@onready var _camera_rig: CameraRig3D = $CameraRig3D


func _get_configuration_warnings() -> PackedStringArray:
   var warnings: PackedStringArray = []

   if $CameraRig3D == null:
      warnings.append('This node does not have a child named and of type \'CameraRig3D\'.')

   return warnings


func _init() -> void:
   if Engine.is_editor_hint():
      return

   Events.camera_region_entered.connect(_on_camera_region_entered)
   Events.camera_region_exited.connect(_on_camera_region_exited)


func _physics_process(delta: float) -> void:
   if Engine.is_editor_hint():
      return

   get_controller().operate_rig(delta, _camera_rig)
   # TODO Camera behaviors?


func _on_camera_region_entered(_target: CameraTarget3D, region: CameraRegion3D):
   _controllers.append(region.camera_controller)
   _resort_controllers()

   # Handle on_enter transition.
   var current_controller := get_controller()
   if (
      current_controller == region.camera_controller
      and _last_chosen_controller != region.camera_controller
   ):
      _last_chosen_controller.on_exit_transition(_camera_rig)
      current_controller.setup_initial_rig_conditions(_camera_rig)
      current_controller.on_enter_transition(_camera_rig)
   else:
      assert(_last_chosen_controller == current_controller, \
         'Region entered was not selected as new camera controller, but controller changed anyway.')
   
   # Update last controller reference
   _last_chosen_controller = current_controller


func _on_camera_region_exited(_target: CameraTarget3D, region: CameraRegion3D):
   _controllers.erase(region.camera_controller)
   _resort_controllers()

   # Handle on_resume transition.
   var current_controller := get_controller()
   if current_controller != _last_chosen_controller:
      _last_chosen_controller.on_exit_transition(_camera_rig)
      current_controller.setup_initial_rig_conditions(_camera_rig)
      current_controller.on_resume_transition(_camera_rig)
   
   # Update last controller reference
   _last_chosen_controller = current_controller


## Sorts the stack of controllers by their own priority values. Maintains first-in-last-
## out relationships between same-priority controllers.
func _resort_controllers() -> void:
   # FIXME Unstable: This doesn't preserve order among same-priority controllers.
   _controllers.sort_custom(
      func (a: CameraRigController3D, b: CameraRigController3D):
         return a.controller_priority < b.controller_priority
   )


## Returns the currently in-focus [CameraRigController3D] of the stack.
## If there are no controllers in the stack, returns the default controller.
func get_controller() -> CameraRigController3D:
   var controller = _controllers.back()
   if controller == null:
      controller = _default_rig_controller
   return controller
