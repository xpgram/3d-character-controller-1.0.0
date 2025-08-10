extends State

@export_group('Transition-to States', 'state_')
@export var state_move: State
@export var state_jump: State
@export var state_fall: State


func on_enter() -> void:
   parent.velocity.x = 0
   parent.velocity.z = 0


func process_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed('jump') and parent.is_on_floor():
      change_state.emit(state_jump)

   if (
      Input.is_action_just_pressed('move_up') or
      Input.is_action_just_pressed('move_down') or
      Input.is_action_just_pressed('move_left') or
      Input.is_action_just_pressed('move_right')
   ):
      change_state.emit(state_move)


func process_physics(delta: float) -> void:
   parent.velocity.y -= physics_properties.prop_physics_gravity * delta
   parent.move_and_slide()

   if !parent.is_on_floor():
      change_state.emit(state_fall)
