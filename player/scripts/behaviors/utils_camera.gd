
## Lerps a [Vector3] toward another, using different lerp weights for different axes.
static func lerp_position(
   from: Vector3,
   to: Vector3,
   ground_plane_weight: float,
   vertical_weight: float,
) -> Vector3:
   var new_height := lerpf(from.y, to.y, vertical_weight)

   from.y = 0
   from = from.lerp(to, ground_plane_weight)
   from.y = new_height

   return from


## Lerps a [Vector3] of axis rotations to another. Interpolates correctly when the angles
## wrap around `@GDScript.TAU`.
static func lerp_rotation(
   from: Vector3,
   to: Vector3,
   weight: float,
) -> Vector3:
   from.x = lerp_angle(from.x, to.x, weight)
   from.y = lerp_angle(from.y, to.y, weight)
   from.z = lerp_angle(from.z, to.z, weight)
   return from
