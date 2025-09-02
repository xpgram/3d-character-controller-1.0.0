@tool
class_name CameraRegion3D
extends Area3D
## An [Area3D] that determines a region of world space that a
## [CameraRigController3D] is responsible for. While a valid camera subject
## (see [CameraTarget3D]) is in contact with this volume, then this volume's
## rig controller should maintain control of an associated camera rig, unless
## it is outbid in priority by another rig controller script.

# TODO Build the script passing process:
#  - CameraRig3D loses 'Subject' as a field, and instead depends on the ControlScript to
#    move its focal point where the subject is.

const WARNING_NO_CAMERA_CONTROLLER := '''
This node has no CameraRigController3D as a child, so cannot define camera
behavior.
'''

const WARNING_TOO_MANY_CAMERA_CONTROLLERS := '''
This node has more than one CameraRigController3D child, so behavior will be
unpredictable.
'''

## A controller to operate a [CameraRig3D].
var camera_controller: CameraRigController3D:
   get():
      if not camera_controller:
         var controllers = get_children() \
            .filter(func (child): return child is CameraRigController3D)

         if len(controllers) > 0:
            camera_controller = controllers[0]
      return camera_controller
   set(controller):
      pass


func _get_configuration_warnings() -> PackedStringArray:
   var warnings: PackedStringArray = []

   var children := get_children()
   var controllers := children.filter(func (child): return child is CameraRigController3D)
   
   if len(controllers) == 0:
      warnings.append(WARNING_NO_CAMERA_CONTROLLER)
   elif len(controllers) > 1:
      warnings.append(WARNING_TOO_MANY_CAMERA_CONTROLLERS)

   return warnings


func _init() -> void:
   monitoring = false
