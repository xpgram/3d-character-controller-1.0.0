extends PlayerControlState


## This State is a splitter between several ground behaviors which may be triggered
## any time a "land" or "ground state reset" may be triggered.

# o on_enter(): call another state change
# o Default state change is to Idle
# o Change to Move if stick is held
# x Change to Crouch if crouch button is held
# x Change to GroundRoll if crouch button and stick are held
#   x GroundRoll:
#     x Sets roll animation in play.
#     x Constantly applies the same move vector until animation is finished (no stick input)
#     x Changes to CrouchWalk state after animation is finished


@export_group('Transition-to States', 'state_')
@export var state_idle: PlayerControlState
@export var state_move: PlayerControlState


func on_enter() -> void:
   var movement_vector := InputUtils.get_raw_movement_vector()

   if not movement_vector.is_zero_approx():
      request_state_change(state_move)
      return

   request_state_change(state_idle)
