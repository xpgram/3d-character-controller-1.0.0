class_name CameraRigCurvePoint3D
extends Resource

## The 3D position of this point in the curve's local space.
@export var rig_position := Vector3.ZERO

## A displacement vector for the curve into this point from the previous index.
@export var curve_in := Vector3.ZERO

## A displacement vector for the curve out from this point to the next index.
@export var curve_out := Vector3.ZERO

## The forward-axis rotation for this point in the curve.
@export var tilt := 0.0


@export_group('Camera Transform')

@export var rig_rotation := Vector3.ZERO

@export var pivot_rotation := Vector3.ZERO

@export var arm_length := Vector3.ZERO

# TODO This is a displacement from subject, right? So how do we implement such a thing?
@export var focal_point := Vector3.ZERO

# TODO Some of these may be hard to implement beneath other camera behaviors.
@export var head_rotation := Vector3.ZERO


@export_group('Camera Settings')

# TODO Shouldn't there be a default value somewhere?
#  Or should I do this proportionally? 50%, 100%, 150%.
@export var camera_fov := 40.0
