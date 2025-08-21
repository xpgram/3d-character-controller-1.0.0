class_name State
extends Node

@warning_ignore('UNUSED_SIGNAL')
signal change_state(new_state: State)

@onready var print_name := name \
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


## State behavior to perform during the startup process.
func on_enter() -> void:
   pass


## State behavior to perform during the shutdown process.
func on_exit() -> void:
   pass


func process_input(_event: InputEvent) -> void:
   pass


func process_frame(_delta: float) -> void:
   pass


func process_physics(_delta: float) -> void:
   pass
