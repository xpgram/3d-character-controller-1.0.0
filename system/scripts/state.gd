class_name State
extends Node


@warning_ignore('UNUSED_SIGNAL')
signal change_state(new_state: State)

@onready
var print_name := name \
   if name.ends_with('State') \
   else (name + ' (State)' as StringName)


func get_state_name() -> String:
   return print_name


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


## Equivalent to _process_physics() when slotted into a [StateMachine].
func process_physics(_delta: float) -> void:
   pass
