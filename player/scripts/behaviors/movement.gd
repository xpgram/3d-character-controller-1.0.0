

## Modifies the given character_body's velocity according to directional input described
## by a [Vector2] over the ground plane. Vector input length is capped to 1. The camera's
## orientation determines the "forward" direction of the vector_input.
static func apply_vector_input_to_character_body(
   delta: float,
   vector_input: Vector2,
   character_body: CharacterBody3D,
   camera: Camera3D, # TODO Make optional: Accept camera orientation vector, provide default.
   physics_properties: PhysicsProperties, # TODO Make optional? There should be some default properties, I guess.
) -> Vector3:

   # This step squares the "strength" of the input vector, allowing finer control near the
   # lower end of the range.
   var curved_input: Vector2 = vector_input * vector_input.length()
   curved_input = curved_input.limit_length(1.0)

   # Camera vectors, normalized to ground plane.
   var forward_vector := camera.global_basis.z.slide(Vector3.UP).normalized()
   var rightward_vector := camera.global_basis.x.slide(Vector3.UP).normalized()

   # Determined direction to move the character body.
   var movement_vector := (
      forward_vector * curved_input.y
      + rightward_vector * curved_input.x
   )

   # Calculate new velocity for this frame.
   var current_velocity := Vector3(character_body.velocity.x, 0, character_body.velocity.z)
   var new_velocity = current_velocity.move_toward(
      movement_vector * physics_properties.prop_move_speed,
      delta * physics_properties.prop_move_acceleration,
   )

   # Snap velocity to "not moving" at low speeds.
   var vector_input_is_none := is_zero_approx(movement_vector.length())
   var velocity_in_dime_stop_range := (new_velocity.length() < physics_properties.prop_move_speed_dimestop_range)

   if vector_input_is_none and velocity_in_dime_stop_range:
      new_velocity = Vector3.ZERO

   # Apply velocity to character body.
   character_body.velocity.x = new_velocity.x
   character_body.velocity.z = new_velocity.z

   # Report the vector used for desired movement.
   return movement_vector
