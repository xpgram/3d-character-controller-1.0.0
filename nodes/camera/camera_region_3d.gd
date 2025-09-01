@tool
class_name CameraRegion3D
extends Area3D

# TODO Build the script passing process:
#  - Player collides with CameraRegion object (this).
#  - CameraRegion calls Events.camera_controller_enabled.emit(self.controller, transition?)
#    - Events is a global script describing a collection of signals.
#    - 'enabled' may be the wrong verbage.
#  - A wrapping node for CameraRig3D, or some other manager, is connected to
#    camera_controller_enabled. It listens for new controllers and passes them along to
#    CameraRig3D, which knows how to use them once it has them.
#  - CameraRig3D loses 'Subject' as a field, and instead depends on the ControlScript to
#    move its focal point where the subject is.

# TODO Transition styles:
#  - Lerp
#    - (By default, I think. More importantly, how do I get it to _not_ lerp?)
#  - Special Script that does whatever it wants
#  - Fade out/in
#  - Fade out, wait, signal in

## A controller to operate a [CameraRig3D].
@export var camera_controller: CameraController


func _get_configuration_warnings() -> PackedStringArray:
   var warnings: PackedStringArray = []

   if camera_controller == null:
      warnings.append('CameraRegion3D has no associated CameraController3D.')

   return warnings


func _init() -> void:
   monitoring = false
