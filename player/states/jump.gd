extends State

const PlayerMovement = preload("res://player/behaviors/movement.gd")


@export_group('Transition-to States', 'state_')
@export var state_idle: State
@export var state_move: State
@export var state_fall: State


@onready var _camera: Camera3D = %Camera3D


var _last_movement_direction := Vector3.BACK


func enter() -> void:
   super()
   parent.velocity.y = physics_properties.prop_move_jump_impulse


func process_physics(delta: float) -> State:
   # TODO This is duplicated among all States? Why?
   parent.velocity.y -= physics_properties.prop_physics_gravity * delta
	
   if parent.velocity.y < 0:
      return state_fall

   var is_ending_jump: float = (Input.is_action_just_released('jump') and (parent.velocity.y > physics_properties.prop_move_min_jump_impulse))

   if is_ending_jump:
      parent.velocity.y = physics_properties.prop_move_min_jump_impulse

   var raw_input = Input.get_vector(
      'move_left',
      'move_right',
      'move_up',
      'move_down',
      0.4
   )

   # TODO This is still fairly obnoxious. I need some better way of handling the
   #   conditional beneath this call.
   var movement_direction = PlayerMovement.apply_vector_input_to_character_body(
      delta,
      raw_input,
      parent,
      _camera,
      physics_properties,
   )
   if movement_direction != Vector3.ZERO:
      _last_movement_direction = movement_direction

   _rotate_character_body(delta)
   parent.move_and_slide()
	
   if parent.is_on_floor():
      if raw_input != Vector2.ZERO:
         return state_move
      else:
         return state_idle

   if parent.is_on_ceiling():
      # TODO Does state_fall have any responsibility to make sure Player is actually moving down?
      parent.velocity.y = 0
      return state_fall
	
   return null


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
