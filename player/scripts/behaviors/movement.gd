
static func get_curved_input_vector(input_vector: Vector2) -> Vector2:
   # This step squares the "strength" of the input vector, allowing finer control near the
   # lower end of the range.
   var curved_input: Vector2 = input_vector * input_vector.length()

   # This step adds x/y banding to the response curve, favoring the cardinal directions
   # while retaining the same "input strength" as was derived in the previous step.
   # TODO How do I vary the gravity of this cardinal attraction? It's too strong.
   var curved_input_length: float = curved_input.length()
   curved_input.x = sign(curved_input.x) * curved_input.x ** 2
   curved_input.y = sign(curved_input.y) * curved_input.y ** 2
   curved_input = curved_input.normalized() * curved_input_length

   curved_input = curved_input.limit_length(1.0)
   
   return curved_input


## Given an input vector and a camera, returns a new input vector as applied to that
## camera's perspective of the ground plane.
static func get_camera_applied_input_vector(
   input_vector: Vector2,
   camera: Camera3D
) -> Vector3:
   # Camera vectors, normalized to ground plane.
   var forward_vector := camera.global_basis.z.slide(Vector3.UP).normalized()
   var rightward_vector := camera.global_basis.x.slide(Vector3.UP).normalized()

   # Determined direction to move the character body.
   var applied_vector := (
      forward_vector * input_vector.y
      + rightward_vector * input_vector.x
   )

   return applied_vector


## Modifies the given character_body's velocity according to directional input described
## by a [Vector2] over the ground plane. Vector input length is capped to 1. The camera's
## orientation determines the "forward" direction of the vector_input.
static func apply_vector_input_to_character_body(
   delta: float,
   input_vector: Vector2,
   character_body: CharacterBody3D,
   camera: Camera3D, # TODO Make optional: Accept camera orientation vector, provide default.
   physics_properties: PhysicsProperties, # TODO Make optional? There should be some default properties, I guess.
) -> Vector3:
   var curved_input := get_curved_input_vector(input_vector)
   var applied_input_vector := get_camera_applied_input_vector(curved_input, camera)

   # Calculate new velocity for this frame.
   var current_velocity := Vector3(character_body.velocity.x, 0, character_body.velocity.z)
   var new_velocity = current_velocity.move_toward(
      applied_input_vector * physics_properties.prop_move_speed,
      delta * physics_properties.prop_move_acceleration,
   )

   # Snap velocity to "not moving" at low speeds.
   var vector_input_is_none := is_zero_approx(applied_input_vector.length())
   var velocity_in_dime_stop_range := (new_velocity.length() < physics_properties.prop_move_speed_dimestop_range)

   if vector_input_is_none and velocity_in_dime_stop_range:
      new_velocity = Vector3.ZERO

   # Apply velocity to character body.
   character_body.velocity.x = new_velocity.x
   character_body.velocity.z = new_velocity.z

   # Report the vector used for desired movement.
   # TODO This is so characters can track "last moved in" direction. Wouldn't this be easier
   #   done another way? Or, why is this function responsible for this data?
   return applied_input_vector


static func get_wall_slide_candidate(
   input_vector: Vector2,
   character_body: CharacterBody3D,
   camera: Camera3D,
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
   var curved_input := get_curved_input_vector(input_vector)
   if curved_input.length() < 0.4: # TODO Get min input strength from physics properties or other
      return false

   # If "push direction" of input vector is not parallel enough with the wall normal over
   # the ground plane, return false.
   var applied_input_vector := get_camera_applied_input_vector(curved_input, camera)
   var negative_wall_normal := -character_body.get_wall_normal()
   var angle_to_wall_normal := applied_input_vector.signed_angle_to(negative_wall_normal, Vector3.UP)

   if abs(angle_to_wall_normal) > PI / 3: # TODO Get max angle from physics properties or other
      return false

   return true
