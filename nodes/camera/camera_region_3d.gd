@tool
class_name CameraRegion3D
extends Area3D
## An [Area3D] that determines a region of world space that a
## [CameraRigOperator3D] is responsible for. While a valid camera subject
## (see [CameraTarget3D]) is in contact with this volume, then this volume's
## rig operator should maintain control of an associated camera rig, unless
## it is outbid in priority by another rig operator script.

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

# TODO Camera controller manager
#  Uses a stack to control behavior.
#  - When a Region is entered, it is placed onto the stack.
#    - The stack is then sorted by priority values. If all are 0, then no order
#       changes occur.
#    - The top of the stack is sent to the CameraRig3D as its new controller.
#  - When a Region is exited, it is removed from the stack, wherever it is.
#    - Stack is resorted.
#    - Topmost controller is picked as new controller.
#  This allows overlapping Regions to manage control flow better.

# TODO Transition styles:
#  - Lerp
#    - (By default, I think. More importantly, how do I get it to _not_ lerp?)
#  - Special Script that does whatever it wants
#  - Fade out/in
#  - Fade out, wait, signal in

const WARNING_NO_CAMERA_OPERATOR := '''
This node has no CameraRigOperator3D as a child, so cannot define camera
behavior.
'''

const WARNING_TOO_MANY_CAMERA_OPERATORS := '''
This node has more than one CameraRigOperator3D child, so behavior will be
unpredictable.
'''

## A controller to operate a [CameraRig3D].
var camera_controller: CameraRigOperator3D:
   get():
      if not camera_controller:
         var operators = get_children() \
            .filter(func (child): return child is CameraRigOperator3D)

         if len(operators) > 0:
            camera_controller = operators[0]
      return camera_controller
   set(rig_operator):
      pass


func _get_configuration_warnings() -> PackedStringArray:
   var warnings: PackedStringArray = []

   var children := get_children()
   var rig_operators := children.filter(func (child): return child is CameraRigOperator3D)
   
   if len(rig_operators) == 0:
      warnings.append(WARNING_NO_CAMERA_OPERATOR)
   elif len(rig_operators) > 1:
      warnings.append(WARNING_TOO_MANY_CAMERA_OPERATORS)

   return warnings


func _init() -> void:
   monitoring = false
