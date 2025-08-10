extends State

# TODO Implement coyote time:
#   - on_enter(): start a timer
#   - Jump from Fall state allowed if timer not fully elapsed
#   - Falling animation not applied until timer fully elapsed


@export_group('Transition-to States', 'state_')
@export var state_idle: State
@export var state_move: State


@onready var _camera: Camera3D = %Camera3D

var _last_movement_direction := Vector3.BACK


func process_physics(delta: float) -> State:
   parent.velocity.y -= physics_properties.prop_physics_gravity * delta

   parent.velocity.y = clampf(
      parent.velocity.y,
      -physics_properties.prop_physics_terminal_velocity,
      physics_properties.prop_physics_terminal_velocity
   )

   var raw_input = Input.get_vector(
      'move_left',
      'move_right',
      'move_up',
      'move_down',
      0.4
   )

   _handle_movement_input(delta, raw_input)
   _rotate_character_body(delta)
   parent.move_and_slide()

   if parent.is_on_floor():
      if raw_input.is_zero_approx():
         return state_idle
      else:
         return state_move

   return null


func _handle_movement_input(delta: float, raw_input: Vector2) -> void:
   # TODO This was pulled from player_3d.gd and likely isn't ready to go.
   # TODO Also... this is the same as ground movement, yes? I think we need layers.
   #   Or, if not layers, common scripts that can be enabled/disabled at will.

   # This step squares the "strength" of the input vector, allowing finer control near the
   # lower end of the range.
   var curved_input: Vector2 = raw_input * raw_input.length()

   var forward_vector := _camera.global_basis.z
   var rightward_vector := _camera.global_basis.x

   var move_direction := (
      forward_vector * curved_input.y +
      rightward_vector * curved_input.x
   )

   # Normalize the camera-angled movement vector onto the ground plane.
   move_direction = move_direction.normalized() * curved_input.length()

   # Calculate new velocity for this frame.
   var lateral_velocity := Vector3(parent.velocity.x, 0, parent.velocity.z)
   var new_velocity = lateral_velocity.move_toward(move_direction * physics_properties.prop_move_speed, physics_properties.prop_move_acceleration * delta)

   var user_input_is_none := is_zero_approx(move_direction.length())
   var velocity_in_dime_stop_range: float = (new_velocity.length() < physics_properties.prop_move_stopping_speed)

   if user_input_is_none and velocity_in_dime_stop_range:
      new_velocity = Vector3.ZERO

   # Move the character
   parent.velocity.x = new_velocity.x
   parent.velocity.z = new_velocity.z

   # Store the last input direction
   if move_direction.length() > 0:
      _last_movement_direction = move_direction


# TODO Accept an argument instead of depending on script-globals?
## Rotates the character body into the direction of travel.
func _rotate_character_body(delta: float) -> void:
   var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)

   # Smoothly rotate to the direction of travel.
   parent._character_model.rotation.y = lerp_angle(
         parent._character_model.rotation.y,
         target_angle,
         physics_properties.prop_move_rotation_speed * _last_movement_direction.length() * delta
   )
