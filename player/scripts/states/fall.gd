extends PlayerControlState

# TODO Implement coyote time:
#   - on_enter(): start a timer
#   - Jump from Fall state allowed if timer not fully elapsed
#   - Falling animation not applied until timer fully elapsed


@export_group('Transition-to States', 'state_')
@export var state_landed: PlayerControlState
@export var state_jump: PlayerControlState
@export var state_wall_slide: PlayerControlState


# TODO What if this doesn't exist?
# @onready var _camera: Camera3D = %Camera3D


var coyote_timer := Timer.new()
var _last_movement_direction := Vector3.BACK


func _ready() -> void:
   coyote_timer.one_shot = true
   coyote_timer.wait_time = physics_properties.prop_move_coyote_time
   coyote_timer.connect('timeout', _on_coyote_timer_timeout)
   add_child(coyote_timer)


func on_enter() -> void:
   # Make sure we're actually falling.
   # TODO What about moving platforms?
   #   Can this be solved with a separate jump_add_velocity vector to isolate the arc?
   if subject.velocity.y > 0:
      subject.velocity.y = 0

   # This step helps transition to the 'wall slide' animation faster.
   # TODO Is there an easier way of doing this? Can we interrupt the 'fall' state transition to insert a new one?
   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)

   if MovementUtils.get_wall_slide_candidate(movement_vector, subject, physics_properties):
      request_state_change(state_wall_slide)
      return

   # Fall state initialization.
   player_model.fall()
   coyote_timer.start()


func process_input(event: InputEvent) -> void:
   # TODO Fall state allows double jump. How should we keep track of jumps done so far?
   if event.is_action_pressed('jump') and coyote_timer.time_left > 0:
      request_state_change(state_jump)


func process_physics(delta: float) -> void:
   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)

   # TODO This clampf only occurs when in Fall state.
   subject.velocity.y = clampf(
      subject.velocity.y,
      -physics_properties.prop_physics_terminal_velocity,
      physics_properties.prop_physics_terminal_velocity
   )

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
   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)

   if subject.is_on_floor():
      request_state_change(state_landed)

   elif MovementUtils.get_wall_slide_candidate(movement_vector, subject, physics_properties):
      request_state_change(state_wall_slide)


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


func _on_coyote_timer_timeout() -> void:
   pass
   # TODO Add falling animation


# func _on_long_fall_timer_timeout() -> void:
#    pass
#    # TODO Add really long fall animation + set up fall damage?
#    #   How do we handle fall damage?
#    #   Ohh, we'd prolly want to transition to a special land_crush state anyway, so
#    #   this'll be down stream of process_physics.
