class_name CameraRigTransform3D
## An object representing the collective transforms for a [CameraRig3D].


## The overall position of the rig object.
var rig_position := Vector3.ZERO

## The overall rotation of the rig object.
var rig_rotation := Vector3.ZERO

## The rotation of the pivot arm. Useful for creating orbit camera effects.
var pivot_rotation := Vector3.ZERO

## The distance of the camera head from the actual position of the rig object.
var arm_length := 0.0

## A point in global space describing where the camera head is looking. Also used to
## inform the depth of field system.
var focal_point := Vector3.ZERO


## Returns a new transform that is the sum of this transform and `param other`.
func add(other: CameraRigTransform3D) -> CameraRigTransform3D:
   var new_transform := CameraRigTransform3D.new()

   new_transform.rig_position = rig_position + other.rig_position
   new_transform.rig_rotation = rig_rotation + other.rig_rotation
   new_transform.pivot_rotation = pivot_rotation + other.pivot_rotation
   new_transform.arm_length = arm_length + other.arm_length
   new_transform.focal_point = focal_point + other.focal_point

   return new_transform
