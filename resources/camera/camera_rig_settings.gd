class_name CameraRigSettings3D
extends Resource


@export_group('Transform')

## If true, then the transform values set here will be instantly assumed by the camera
## rig itself.
@export
var skip_animation := false

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

## The point (using global coordinates) describing where the camera is looking. Also used
## to inform the depth of field system.
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
var pivot_arm_max_rotation := Vector3.ONE * 180

## How far the camera zooms in when the pivot arm is being rotated toward one of its axis
## limits. This means the actual zoom is proportional to the actual rotation.
@export var camera_tilt_zoom_distance: float = 4.0