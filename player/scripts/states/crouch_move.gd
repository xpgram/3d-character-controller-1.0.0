extends PlayerControlState


@export_group('Transition-to States', 'state_')
@export var state_crouch_idle: PlayerControlState
@export var state_move: PlayerControlState
@export var state_jump: PlayerControlState
@export var state_fall: PlayerControlState


# TODO Instantiate to PlayerBody or something.
#   If all I want is the possibility for couch-coop, then something like that should be
#   fine, right? Why am I reimplementing this var every single script that can move.
var _last_movement_direction := Vector3.BACK


func on_enter() -> void:
   player_model.crawl()


func process_physics(delta: float) -> void:
   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)

   if is_zero_approx(movement_vector.length()):
      change_state.emit(state_crouch_idle)
      return

   var moved_direction := MovementUtils.apply_vector_input_to_character_body(
      delta,
      movement_vector,
      subject,
      physics_properties,
   )

   if moved_direction != Vector3.ZERO:
      _last_movement_direction = moved_direction

   _rotate_character_body(delta)

   if !subject.is_on_floor():
      change_state.emit(state_fall)


func process_input(_event: InputEvent) -> void:
   if Input.is_action_just_released('crouch') and subject.is_on_floor():
      change_state.emit(state_move)
      return

   if Input.is_action_just_pressed('jump') and subject.is_on_floor():
      change_state.emit(state_jump)


# TODO Accept an argument instead of depending on script-globals?
## Rotates the character body into the direction of travel.
func _rotate_character_body(delta: float) -> void:
   # TODO Whyyy is "forward" Vector3.BACK??
   var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)

   # Smoothly rotate to the direction of travel.
   subject._character_model.rotation.y = lerp_angle(
         subject._character_model.rotation.y,
         target_angle,
         physics_properties.prop_move_rotation_speed * _last_movement_direction.length() * delta
   )
