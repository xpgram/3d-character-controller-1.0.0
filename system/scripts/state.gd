class_name State
extends Node


@warning_ignore('UNUSED_SIGNAL')
signal change_state(requester: State, new_state: State)

@onready
var print_name := name \
   if name.ends_with('State') \
   else (name + ' (State)' as StringName)


func get_state_name() -> String:
   return print_name


func request_state_change(new_state: State) -> void:
   change_state.emit(self, new_state)


## Handle the State startup process.
func enter() -> void:
   on_enter()


## Handle the State exit process.
func exit() -> void:
   on_exit()


## Called by the owning [StateMachine] during its _unhandled_input() step.
## This calls other input-related substeps.
func process_input_machine_hook(event: InputEvent) -> void:
   process_input(event)


## Called by the owning [StateMachine] during its _process() step.
## This calls other process-related substeps.
func process_frame_machine_hook(delta: float) -> void:
   process_frame(delta)


## Called by the owning [StateMachine] during its _process_physics() step.
## This calls other physics-related substeps.
func process_physics_machine_hook(delta: float) -> void:
   process_world_physics(delta)
   process_physics(delta)


## State behavior to perform during the startup process.
func on_enter() -> void:
   pass


## State behavior to perform during the shutdown process.
func on_exit() -> void:
   pass

## Equivalent to _unhandled_input() when slotted into a [StateMachine].
func process_input(_event: InputEvent) -> void:
   pass


## Equivalent to _process() when slotted into a [StateMachine].
func process_frame(_delta: float) -> void:
   pass


## Runs before the _process_physics() step when slotted into a [StateMachine].
## This step is useful for managing physics processes that are applied no matter
## which State controller is currently active, such as gravity.
##
## An example using a player state controller:
## `State -> PlayerState : implements process_world_physics()`
## `State -> PlayerState -> PlayerMoveState : implements process_physics()`
func process_world_physics(_delta: float) -> void:
   pass
   # TODO The Strategy pattern.
   #  This might prove more useful? Imagine having a list of configurable effects
   #  that get added kinda like a tagging system. Then, before the controller's
   #  physics pass, they all each add their own velocity changes and whatnot just
   #  like world_physics does now.
   #  But like, you could collide with a wind-area, and it could temporarily add
   #  add_force(acceleration, direction) to you until you leave.
   #  Gravity could just be add_force(30, down) that never leaves.
   #
   #  I'm still not sure.


## Equivalent to _process_physics() when slotted into a [StateMachine].
func process_physics(_delta: float) -> void:
   pass
