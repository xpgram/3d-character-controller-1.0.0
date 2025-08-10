extends Node

@export var starting_state: State

@onready var states_container := $States


var state_machine_name: String
var current_state: State
var next_state: State


# TODO Do state_machines always have a CharacterBody3D-like subject?
#   I'd prefer a template type, but I don't know if that's even an option in gdscript.
func init(machine_name: String, parent: CharacterBody3D) -> void:
   state_machine_name = machine_name

   var children = states_container.get_children()

   # TODO Not working
   # var state_nodes = children.filter(func(child): typeof(child) == typeof(State))

   for state_mode: State in children:
      state_mode.parent = parent # TODO Change 'parent' to something else.
      state_mode.change_state.connect(request_state_change)

   next_state = starting_state
   change_state_to_next()


func request_state_change(new_state: State) -> void:
   next_state = new_state


func change_state_to_next() -> void:
   var loop_count := 0

   while next_state:
      if current_state:
         current_state.exit()

      current_state = next_state

      # enter() may emit request_state_change, so must occur after next_state is cleared.
      next_state = null
      current_state.enter()

      # Raise an exception if we've found an infinite loop.
      loop_count += 1
      if loop_count > 100:
         assert(false, "State machine '%s' is stuck in an infinite loop." % state_machine_name)
         break


func process_input(event: InputEvent) -> void:
   current_state.process_input(event)
   change_state_to_next()


func process_frame(delta: float) -> void:
   current_state.process_frame(delta)
   change_state_to_next()


func process_physics(delta: float) -> void:
   current_state.process_physics(delta)
   change_state_to_next()
