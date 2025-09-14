@tool
class_name CameraBehavior_ResetProperties
extends ICameraRigBehavior3D
## Sets a baseline for future additive behaviors by setting static values to camera rig
## properties.


# Rig Position
var reset_rig_position := true:
   set(value):
      reset_rig_position = value
      notify_property_list_changed()
var rig_position := Vector3.ZERO

# Rig Rotation
var reset_rig_rotation := true:
   set(value):
      reset_rig_rotation = value
      notify_property_list_changed()
var rig_rotation := Vector3.ZERO

# Pivot Rotation
var reset_pivot_rotation := true:
   set(value):
      reset_pivot_rotation = value
      notify_property_list_changed()
var pivot_rotation := Vector3.ZERO

# Arm Length
var reset_arm_length := true:
   set(value):
      reset_arm_length = value
      notify_property_list_changed()
var arm_length := 0.0

# Focal Point
var reset_focal_point := true:
   set(value):
      reset_focal_point = value
      notify_property_list_changed()
var focal_point := Vector3.ZERO


func _get_property_list() -> Array[Dictionary]:
   if not Engine.is_editor_hint():
      return []

   var properties: Array[Dictionary] = []

   properties.append({
      'name': &"Transforms",
      'type': TYPE_NIL,
      'usage': PROPERTY_USAGE_GROUP,
   })
   properties.append({
      'name': &'reset_rig_position',
      'type': TYPE_BOOL,
   })
   if reset_rig_position:
      properties.append({
         'name': &'rig_position',
         'type': TYPE_VECTOR3,
         'hint': PROPERTY_HINT_NONE,
         'hint_string': 'suffix:m'
      })
   properties.append({
      'name': &'reset_rig_rotation',
      'type': TYPE_BOOL,
   })
   if reset_rig_rotation:
      properties.append({
         'name': &'rig_rotation',
         'type': TYPE_VECTOR3,
         'hint': PROPERTY_HINT_NONE,
         'hint_string': 'suffix:°'
      })
   properties.append({
      'name': &'reset_pivot_rotation',
      'type': TYPE_BOOL,
   })
   if reset_pivot_rotation:
      properties.append({
         'name': &'pivot_rotation',
         'type': TYPE_VECTOR3,
         'hint': PROPERTY_HINT_NONE,
         'hint_string': 'suffix:°'
      })
   properties.append({
      'name': &'reset_arm_length',
      'type': TYPE_BOOL,
   })
   if reset_arm_length:
      properties.append({
         'name': &'arm_length',
         'type': TYPE_FLOAT,
         'hint': PROPERTY_HINT_NONE,
         'hint_string': 'suffix:m'
      })
   properties.append({
      'name': &'reset_focal_point',
      'type': TYPE_BOOL,
   })
   if reset_focal_point:
      properties.append({
         'name': &'rig_focal_point',
         'type': TYPE_VECTOR3,
         'hint': PROPERTY_HINT_NONE,
         'hint_string': 'suffix:m'
      })

   return properties


func update_camera_rig(_delta: float, camera_rig: CameraRig3D) -> void:
   if reset_rig_position:
      camera_rig.position = rig_position
   if reset_rig_rotation:
      camera_rig.rotation = rig_rotation
   if reset_pivot_rotation:
      camera_rig.pivot_rotation = pivot_rotation
   if reset_arm_length:
      camera_rig.arm_length = arm_length
   if reset_focal_point:
      camera_rig.focal_point = focal_point
