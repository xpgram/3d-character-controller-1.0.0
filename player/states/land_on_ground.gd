extends State

# TODO This State is a splitter between several ground behaviors which may be triggered
#   any time a "land" or "ground state reset" may be triggered.

# - on_enter(): call another state change
# - Default state change is to Idle
# - Change to Move if stick is held
# - Change to Crouch if crouch button is held
# - Change to GroundRoll if crouch button and stick are held
#   - GroundRoll:
#     - Sets roll animation in play.
#     - Constantly applies the same move vector until animation is finished (no stick input)
#     - Changes to CrouchWalk state after animation is finished

