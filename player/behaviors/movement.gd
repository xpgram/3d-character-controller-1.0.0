

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
   
   var forward_vector := camera.global_basis.z
   var rightward_vector := camera.global_basis.x
   
   var move_direction := (
      forward_vector * curved_input.y +
      rightward_vector * curved_input.x
   )

   # Normalize the camera-angled movement vector onto the ground plane.
   # TODO This doesn't do its job: tilting the camera up makes you move slower.
   move_direction = move_direction.normalized() * curved_input.length()

   # Calculate new velocity for this frame.
   var lateral_velocity := Vector3(character_body.velocity.x, 0, character_body.velocity.z)
   var new_velocity = lateral_velocity.move_toward(move_direction * physics_properties.prop_move_speed, physics_properties.prop_move_acceleration * delta)

   var user_input_is_none := is_zero_approx(move_direction.length())
   var velocity_in_dime_stop_range: float = (new_velocity.length() < physics_properties.prop_move_stopping_speed)

   if user_input_is_none and velocity_in_dime_stop_range:
      new_velocity = Vector3.ZERO

   # Move the character
   character_body.velocity.x = new_velocity.x
   character_body.velocity.z = new_velocity.z

   # Store the last input direction
   if move_direction.length() > 0:
      # _last_movement_direction
      return move_direction

   # TODO Vec(0,0,0) is supposed to be ignored.
   # I don't remember what this value's purpose is, though.
   # This is for spinning the character accurately.
   # TODO This should return move_direction without applying it, maybe?
   # move_and_slide() must still be called elsewhere anyway, yeah?
   return move_direction

   # var direction_moved := PlayerMovement.apply_stick_input_to_entity_velocity(...)
   # last_direction_moved = direction_moved
   # character.move_and_slide()
   #
   # vs.:
   #
   # var move_direction := PlayerMovement.
   # 
   #
   #
   # vs.:
   #
   # character.apply_stick_input_to_velocity(...)
   # character.spin_to_direction()
   # character.move_and_slide()

