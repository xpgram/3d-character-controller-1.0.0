extends State

@export_group('Transition-to States', 'state_')
@export var state_move: State
@export var state_jump: State
@export var state_fall: State


func on_enter() -> void:
   subject.velocity.x = 0
   subject.velocity.z = 0


func process_input(_event: InputEvent) -> void:
   if Input.is_action_just_pressed('jump') and subject.is_on_floor():
      change_state.emit(state_jump)

   if (
      Input.is_action_just_pressed('move_up') or
      Input.is_action_just_pressed('move_down') or
      Input.is_action_just_pressed('move_left') or
      Input.is_action_just_pressed('move_right')
   ):
      change_state.emit(state_move)


func process_physics(delta: float) -> void:
   subject.velocity.y -= physics_properties.prop_physics_gravity * delta
   subject.move_and_slide()

   if !subject.is_on_floor():
      change_state.emit(state_fall)
