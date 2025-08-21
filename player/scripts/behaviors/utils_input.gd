# TODO To expose in Game Settings, this should be a resource associated with a
#   player profile. I need to think about how that works, though.
const STICK_DEADZONE := 0.25


## Given a [Vector2], returns a [Vector2] in the same direction with a length
## value adjusted to follow a quadratic curve. This allows finer control near
## the lower end of the range.
static func apply_wide_response_curve(vector: Vector2) -> Vector2:
   var curved_vector := vector * vector.length()
   curved_vector = curved_vector.limit_length(1.0)
   return curved_vector


## Given a [Vector2], returns a [Vector2] of the same length in a direction that
## slightly favors the orthogonal axis directions.
static func apply_orthogonal_banding(vector: Vector2) -> Vector2:
   var banded_vector := Vector2(vector)
   var vector_length := vector.length()

   # Apply quadratic banding to each axis.
   banded_vector.x = sign(banded_vector.x) * banded_vector.x ** 2
   banded_vector.y = sign(banded_vector.y) * banded_vector.y ** 2

   # Retain original length of vector.
   banded_vector = banded_vector.normalized() * vector_length

   return banded_vector


## Given a [Vector2], returns a [Vector3] oriented in 3D space and projected
## onto a plane described by plane_normal.
##
## Ex: `apply_basis(left_stick_input, camera3d.global_basis, Vector3.UP)`
## This function call returns a Vector3 for movement input oriented to the
## perspective of the camera, but limited to the ground plane, which prevents
## forward movement input from ever being directed into the floor.
static func apply_basis(
   vector: Vector2,
   basis: Basis,
   plane_normal: Vector3 = Basis.IDENTITY.y,
) -> Vector3:
   # Direction vectors are derived from the basis ZX-plane projected onto the
   # plane described by plane_normal.
   var forward_vector   := basis.z.slide(plane_normal).normalized()
   var rightward_vector := basis.x.slide(plane_normal).normalized()

   var reoriented_vector := (
      forward_vector * vector.y
      + rightward_vector * vector.x
   )

   return reoriented_vector


## Returns an unprocessed [Vector2] for left-stick input.
static func get_raw_movement_vector() -> Vector2:
   return Input.get_vector(
      'move_left',
      'move_right',
      'move_up',
      'move_down',
      STICK_DEADZONE,
   )


## Returns an unprocessed [Vector2] for right-stick input.
static func get_raw_camera_look_vector() -> Vector2:
   return Input.get_vector(
      'look_left',
      'look_right',
      'look_up',
      'look_down',
      STICK_DEADZONE,
   )


## Returns a [Vector2] representing left-stick input.
static func get_movement_vector(
   basis: Basis = Basis.IDENTITY,
   plane_normal: Vector3 = Vector3.UP,
) -> Vector3:
   var vector2 := get_raw_movement_vector()
   vector2 = apply_wide_response_curve(vector2)
   vector2 = apply_orthogonal_banding(vector2)
   var vector3 = apply_basis(vector2, basis, plane_normal)
   return vector3


## Returns a [Vector2] representing right-stick input.
static func get_camera_look_vector() -> Vector2:
   var vector := get_raw_camera_look_vector()
   vector = apply_wide_response_curve(vector)
   return vector
