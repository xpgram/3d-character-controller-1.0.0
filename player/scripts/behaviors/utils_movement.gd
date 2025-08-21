
## Applies gravity to a character body's velocity.
static func apply_gravity(
   delta: float,
   character_body: CharacterBody3D,
   acceleration: float = 9.0,
   up_vector: Vector3 = Vector3.UP,
) -> void:
   var gravity_vector := -up_vector * acceleration * delta
   character_body.velocity = character_body.velocity + gravity_vector


## Modifies the given character_body's velocity according to directional input described
## by a [Vector2] over the ground plane. Vector input length is capped to 1. The camera's
## orientation determines the "forward" direction of the vector_input.
static func apply_vector_input_to_character_body(
   delta: float,
   movement_vector: Vector3,
   character_body: CharacterBody3D,
   physics_properties: PhysicsProperties, # TODO If character_body has component, use, else preload a default set of values.
) -> Vector3:
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
   # TODO This is so characters can track "last moved in" direction. Wouldn't this be easier
   #   done another way? Or, why is this function responsible for this data?
   return movement_vector


static func get_wall_slide_candidate(
   movement_vector: Vector3,
   character_body: CharacterBody3D,
   physics_properties: PhysicsProperties,
) -> bool:
   # TODO Shouldn't this return the wall collided with? How do I do that?

   if character_body.is_on_floor() or not character_body.is_on_wall():
      return false

   # TODO If collided walls are 2+, then return false. (Covers corners and other odd situations.)

   # TODO If 1 collided wall was not first collided with on this frame, return false.
   #   i.e., wall must be collided in the air (prevents frustration when jumping at wall's base.)
   #   Could also use a collision timestamp and input window to avoid single-frame activation.
   #   Also, what about jumping along a wall, turning the stick to move _over_ it, and accidentally
   #     triggering the wall slide? This happens when trying to mantle.

   # TODO If wall is in wrong collision layer, or otherwise marked "not slidable," return false.
   #   e.g., invisible barriers should not be wall-jump enabled.

   # If "push strength" of input vector is too low, return false.
   if movement_vector.length() < 0.4: # TODO Get min input strength from physics properties or other
      return false

   # If "push direction" of input vector is not parallel enough with the wall normal over
   # the ground plane, return false.
   var negative_wall_normal := -character_body.get_wall_normal()
   var angle_to_wall_normal := movement_vector.signed_angle_to(negative_wall_normal, Vector3.UP)

   if abs(angle_to_wall_normal) > PI / 3: # TODO Get max angle from physics properties or other
      return false

   return true
