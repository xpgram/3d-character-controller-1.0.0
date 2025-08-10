extends State

# TODO Implement coyote time:
#   - on_enter(): start a timer
#   - Jump from Fall state allowed if timer not fully elapsed
#   - Falling animation not applied until timer fully elapsed


const PlayerMovement = preload("uid://bc4pn1ojhofxm")


# TODO Use preload() calls and such instead of nodes.
@export_group('Transition-to States', 'state_')
@export var state_idle: State
@export var state_move: State
@export var state_jump: State


# TODO What if this doesn't exist?
@onready var _camera: Camera3D = %Camera3D


var coyote_timer := Timer.new()
var _last_movement_direction := Vector3.BACK


func _ready() -> void:
   coyote_timer.one_shot = true
   coyote_timer.wait_time = physics_properties.prop_move_coyote_time
   coyote_timer.connect('timeout', _on_coyote_timer_timeout)
   add_child(coyote_timer)


func on_enter() -> void:
   coyote_timer.start()


func process_input(event: InputEvent) -> void:
   # TODO Fall state allows double jump. How should we keep track of jumps done so far?
   if event.is_action_pressed('jump') and coyote_timer.time_left > 0:
      change_state.emit(state_jump)


func process_physics(delta: float) -> void:
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
      if raw_input.is_zero_approx():
         change_state.emit(state_idle)
      else:
         change_state.emit(state_move)


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


func _on_coyote_timer_timeout() -> void:
   pass
   # TODO Add falling animation


# func _on_long_fall_timer_timeout() -> void:
#    pass
#    # TODO Add really long fall animation + set up fall damage?
#    #   How do we handle fall damage?
#    #   Ohh, we'd prolly want to transition to a special land_crush state anyway, so
#    #   this'll be down stream of process_physics.
