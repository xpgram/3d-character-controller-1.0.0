extends State

const PlayerMovement = preload("res://player/behaviors/movement.gd")

@export_group('Transition-to States', 'state_')
@export var state_idle: State
@export var state_jump: State
@export var state_fall: State


# TODO Technically, this node shouldn't know about the camera node.
@onready var _camera: Camera3D = %Camera3D


var _last_movement_direction := Vector3.BACK


func process_physics(delta: float) -> State:
   parent.velocity.y -= physics_properties.prop_physics_gravity * delta

   var raw_input = Input.get_vector(
      'move_left',
      'move_right',
      'move_up',
      'move_down',
      0.4
   )

   if raw_input == Vector2.ZERO:
      return state_idle

   _handle_movement_input(delta, raw_input)
   _rotate_character_body(delta)
   parent.move_and_slide()

   if !parent.is_on_floor():
      return state_fall

   return null


func process_input(_event: InputEvent) -> State:
   if Input.is_action_just_pressed('jump') and parent.is_on_floor():
      return state_jump
   
   return null


func _handle_movement_input(delta: float, raw_input: Vector2) -> void:
   var moved_direction := PlayerMovement.move_entity_by_stick_input(
      delta,
      raw_input,
      parent,
      _camera,
      physics_properties,
   )

   if moved_direction != Vector3.ZERO:
      _last_movement_direction = moved_direction


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
