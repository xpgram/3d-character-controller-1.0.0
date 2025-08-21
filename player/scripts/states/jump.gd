extends PlayerControlState

const InputUtils := preload('uid://tl2nnbstems3')
const MovementUtils = preload('uid://bc4pn1ojhofxm')


@export_group('Transition-to States', 'state_')
@export var state_landed: PlayerControlState
@export var state_fall: PlayerControlState


# @onready var _camera: Camera3D = %Camera3D


var _last_movement_direction := Vector3.BACK


func on_enter() -> void:
   player_model.jump()
   subject.velocity.y = physics_properties.prop_move_jump_impulse


func process_physics(delta: float) -> void:
   var velocity1 := Vector3(subject.velocity)
   MovementUtils.apply_gravity(delta, subject, physics_properties.prop_physics_gravity)
   var velocity2 := Vector3(subject.velocity)
   print('velocity old %.2f == %.2f new' % [velocity1.y, velocity2.y])

   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)
	
   if subject.velocity.y < 0:
      change_state.emit(state_fall)
      return

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
   subject.move_and_slide()
	
   if subject.is_on_floor():
      change_state.emit(state_landed)
      return

   if subject.is_on_ceiling():
      # TODO Does state_fall have any responsibility to make sure Player is actually moving down?
      subject.velocity.y = 0
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
