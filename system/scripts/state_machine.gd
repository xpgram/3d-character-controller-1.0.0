extends Node

@export var starting_state: State

@onready var states_container := $States


var state_machine_name: String
var current_state: State
var next_state: State


# TODO Do state_machines always have a CharacterBody3D-like subject?
#   I'd prefer a template type, but I don't know if that's even an option in gdscript.
func init(machine_name: String, subject: CharacterBody3D, camera: Camera3D) -> void:
   state_machine_name = machine_name

   # Collect all State objects and initialize them.
   var state_nodes: Array[State]
   state_nodes.assign(states_container
      .get_children()
      .filter(func(child): return child is State)
   )

   for state_node in state_nodes:
      state_node.init(subject, camera)
      state_node.change_state.connect(request_state_change)

   next_state = starting_state
   change_state_to_next()


func request_state_change(requester: State, new_state: State) -> void:
   if requester != current_state:
      push_warning(
         'StateMachine %s: InvalidRequest: "%s" requested a state change to "%s", but current state is "%s"' \
         % [state_machine_name, requester.print_name, new_state.print_name, current_state.print_name]
      )
      return

   if next_state:
      push_warning(
         'StateMachine %s: OverriddenRequest: next_state "%s" is being overridden with "%s" as requested by "%s"' \
         % [state_machine_name, next_state.print_name, new_state.print_name, requester.print_name]
      )

   next_state = new_state


func change_state_to_next() -> void:
   var loop_count := 0

   while next_state:
      if current_state:
         current_state.exit()

      current_state = next_state
      # TODO Add some kind of debug logging thing here.
      # print(current_state.print_name)

      # enter() may emit request_state_change, so must occur after next_state is cleared.
      next_state = null
      current_state.enter()

      # Raise an exception if we've found an infinite loop.
      loop_count += 1
      if loop_count > 100:
         assert(false, "State machine '%s' is stuck in an infinite loop." % state_machine_name)
         break


func process_input(event: InputEvent) -> void:
   current_state.process_input_machine_hook(event)
   change_state_to_next()


func process_frame(delta: float) -> void:
   current_state.process_frame_machine_hook(delta)
   change_state_to_next()


func process_physics(delta: float) -> void:
   current_state.process_physics_machine_hook(delta)
   change_state_to_next()
