extends PlayerControlState


@export_group('Transition-to States', 'state_')
@export var state_landed: PlayerControlState
@export var state_fall: PlayerControlState


var _last_movement_direction := Vector3.BACK


func on_enter() -> void:
   player_model.jump()
   subject.velocity.y = physics_properties.prop_move_jump_impulse


func process_physics(delta: float) -> void:
   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)
   var is_ending_jump: float = (Input.is_action_just_released('jump') and (subject.velocity.y > physics_properties.prop_move_min_jump_impulse))

   if is_ending_jump:
      subject.velocity.y = physics_properties.prop_move_min_jump_impulse

   # TODO This is still fairly obnoxious. I need some better way of handling the
   #   conditional beneath this call.
   var movement_direction = MovementUtils.apply_vector_input_to_character_body(
      delta,
      movement_vector,
      subject,
      physics_properties,
   )
   if movement_direction != Vector3.ZERO:
      _last_movement_direction = movement_direction

   _rotate_character_body(delta)


func post_physics_check() -> void:
   if subject.is_on_floor():
      change_state.emit(state_landed)

   # TODO The post_physics_check() change has proven a bit buggy.
   #   I haven't tracked down the issue yet, though.
   #   Anyway, somewhere between Jump, Fall, and WallSlide there is an issue
   #   with jumping up against a wall terminating the jump early.
   #   is_on_ceiling() is the only good guess I have.
   elif subject.is_on_ceiling() or subject.velocity.y < 0:
      change_state.emit(state_fall)


# TODO Accept an argument instead of depending on script-globals?
## Rotates the character body into the direction of travel.
func _rotate_character_body(delta: float) -> void:
   var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)

   # Smoothly rotate to the direction of travel.
   subject._character_model.rotation.y = lerp_angle(
         subject._character_model.rotation.y,
         target_angle,
         physics_properties.prop_move_rotation_speed * _last_movement_direction.length() * delta
   )
