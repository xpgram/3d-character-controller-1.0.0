extends State

const InputUtils = preload('uid://tl2nnbstems3')
const MovementUtils = preload("uid://bc4pn1ojhofxm")

@export_group('Transition-to States', 'state_')
@export var state_idle: State
@export var state_jump: State
@export var state_fall: State 
@export var state_crouch_move: State 


# TODO Technically, this node shouldn't know about the camera node.
# @onready var _camera: Camera3D = %Camera3D


var _last_movement_direction := Vector3.BACK


func on_enter() -> void:
   player_model.move()


func process_physics(delta: float) -> void:
   subject.velocity.y -= physics_properties.prop_physics_gravity * delta

   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)
   
   if movement_vector.is_zero_approx():
      change_state.emit(state_idle)
      return

   if Input.is_action_just_pressed('crouch') and subject.is_on_floor():
      change_state.emit(state_crouch_move)
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
   subject.move_and_slide()

   if !subject.is_on_floor():
      change_state.emit(state_fall)


func process_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed('jump') and subject.is_on_floor():
      change_state.emit(state_jump)


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

   # TODO Add tilt
   # player_model._set_run_tilt(0.0)
