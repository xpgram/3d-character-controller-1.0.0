class_name CameraRigSettings3D
extends Resource
## A resource to contain the litany of [CameraRig3D] options. Also lightly manages some
## of these options' values.

# TODO Change this class' name.
#  This kinda represents the Rig's transform, but I already have a struct-like object
#  called CameraRigTransform, so... I dunno.


@export_group('Transform')

## If true, then the transform values set here will be instantly assumed instead of being
## tweened to.
@export
var disable_animation := false

## The position of the rig object.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var rig_position := Vector3.ZERO

## The rotation of the rig object.
@export_custom(PROPERTY_HINT_NONE, 'radians, suffix:°')
var rig_rotation := Vector3.ZERO

## The rotation of the pivot arm. Useful for managing a player's rotational input even
## while the rig itself is rotated.
@export_custom(PROPERTY_HINT_NONE, 'radians, suffix:°')
var pivot_rotation := Vector3.ZERO

## The distance from the rig's position to where the camera head is located.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var arm_length: float = 0

## A point in global space describing where the camera head is looking. Also used to
## inform the depth of field system.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var focal_point := Vector3.ZERO

## A second `property rig_position` value that may remain constant. Useful for setting a
## known distance from a moving point of view while otherwise locking onto its position.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var rig_position_displacement := Vector3.ZERO

## A second `property focal_point` value that may remain constant. Useful for setting a
## known distance from a subject of focus while otherwise locking onto its position.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var focal_point_displacement := Vector3.ZERO


@export_group('Lerp rates', 'lerp_rate_')

## The rate at which the rig's actual position meets its set position.
## This is used in the formula `rate * frame_delta * distance`.
@export_custom(PROPERTY_HINT_LINK, 'suffix:r')
var lerp_rate_rig_position := Vector3.ONE

## The rate at which the rig's actual rotation meets its set rotation.
## This is used in the formula `rate * frame_delta * distance`.
@export_custom(PROPERTY_HINT_LINK, 'suffix:r')
var lerp_rate_rig_rotation := Vector3.ONE

## The rate at which the rig's actual pivot rotation meets its set rotation.
## This is used in the formula `rate * frame_delta * distance`.
@export_custom(PROPERTY_HINT_LINK, 'suffix:r')
var lerp_rate_pivot_rotation := Vector3.ONE

## The rate at which the rig's actual arm length meets its set length.
## This is used in the formula `rate * frame_delta * distance`.
@export_custom(PROPERTY_HINT_NONE, 'suffix:r')
var lerp_rate_arm_length: float = 1

## The rate at which the rig's focal point position meets its set position.
## This is used in the formula `rate * frame_delta * distance`.
@export_custom(PROPERTY_HINT_LINK, 'suffix:r')
var lerp_rate_focal_point := Vector3.ONE


# FIXME These are settings that kind of only make sense for a particular kind of camera.
#  max_rotation is maybe excusable, but tilt_zoom_distance only makes sense as part of a
#  user input strategy. These should be factored out into a separate "common behaviors"
#  thing.
@export_group('Pivot Arm Settings', 'pivot_arm_')

## How far in degrees the pivot arm is allowed to rotate in each axis.
## A value of 180° or higher means there is no limit.
@export_custom(PROPERTY_HINT_RANGE, '0, 180, or_greater, radians, suffix:°')
var pivot_arm_max_rotation := Vector3.ONE * PI

## How far the camera zooms in when the pivot arm is being rotated toward one of its axis
## limits. This means the actual zoom is proportional to the actual rotation.
@export var pivot_arm_tilt_zoom_distance: float = 4.0


## A transform that represents the Rig's actual position values. This is continuously
## lerped toward the intended transform values described by the exported fields.
var _actual_transform := CameraRigTransform3D.new()


func _init() -> void:
   skip_animation()


## Returns transform values representing the intended transform of the Rig. That is, the
## values that the Rig's actual transform is being animated toward.
func get_intended_transform() -> CameraRigTransform3D:
   var rig_transform := CameraRigTransform3D.new()
   rig_transform.rig_position = rig_position
   rig_transform.rig_rotation = rig_rotation
   rig_transform.pivot_rotation = pivot_rotation
   rig_transform.arm_length = arm_length
   rig_transform.focal_point = focal_point
   return rig_transform


## Returns transform values representing the current transform of the Rig.
func get_actual_transform() -> CameraRigTransform3D:
   return _actual_transform


## Moves the actual transform values toward the intended transform.
func lerp_transform(delta: float) -> void:
   if disable_animation:
      skip_animation()
      return
   
   # Apply vector displacements.
   var complete_rig_position := rig_position + rig_position_displacement
   var complete_focal_point := focal_point + focal_point_displacement

   # Lerp actual_transform to the intended transform.
   # TODO Is this level of granularity too much? Especially considering it probably suffers the 1.4 diagonal problem.
   _actual_transform.rig_position.x = lerp(_actual_transform.rig_position.x, complete_rig_position.x, lerp_rate_rig_position.x * delta)
   _actual_transform.rig_position.y = lerp(_actual_transform.rig_position.y, complete_rig_position.y, lerp_rate_rig_position.y * delta)
   _actual_transform.rig_position.z = lerp(_actual_transform.rig_position.z, complete_rig_position.z, lerp_rate_rig_position.z * delta)

   _actual_transform.rig_rotation.x = lerp_angle(_actual_transform.rig_rotation.x, rig_rotation.x, lerp_rate_rig_rotation.x * delta)
   _actual_transform.rig_rotation.y = lerp_angle(_actual_transform.rig_rotation.y, rig_rotation.y, lerp_rate_rig_rotation.y * delta)
   _actual_transform.rig_rotation.z = lerp_angle(_actual_transform.rig_rotation.z, rig_rotation.z, lerp_rate_rig_rotation.z * delta)

   _actual_transform.pivot_rotation.x = lerp_angle(_actual_transform.pivot_rotation.x, pivot_rotation.x, lerp_rate_pivot_rotation.x * delta)
   _actual_transform.pivot_rotation.y = lerp_angle(_actual_transform.pivot_rotation.y, pivot_rotation.y, lerp_rate_pivot_rotation.y * delta)
   _actual_transform.pivot_rotation.z = lerp_angle(_actual_transform.pivot_rotation.z, pivot_rotation.z, lerp_rate_pivot_rotation.z * delta)

   _actual_transform.arm_length = lerp(_actual_transform.arm_length, arm_length, lerp_rate_arm_length * delta)

   _actual_transform.focal_point.x = lerp(_actual_transform.focal_point.x, complete_focal_point.x, lerp_rate_focal_point.x * delta)
   _actual_transform.focal_point.y = lerp(_actual_transform.focal_point.y, complete_focal_point.y, lerp_rate_focal_point.y * delta)
   _actual_transform.focal_point.z = lerp(_actual_transform.focal_point.z, complete_focal_point.z, lerp_rate_focal_point.z * delta)


## Instantly applies the intended transform values to the actual transform, skipping all
## lerp animations.
func skip_animation() -> void:
   _actual_transform = get_intended_transform()
