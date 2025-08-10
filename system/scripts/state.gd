class_name State
extends Node

@export var animation_name: String


# TODO These are not generic.
@onready var physics_properties := %PhysicsProperties
@onready var ui_player_state_label := %DebugOutput_PlayerState


var parent: Player


func get_state_name() -> String:
   # TODO This also isn't generic.
   return "Player state: " + name


## Handle the State startup process.
func enter() -> void:
   ui_player_state_label.text = get_state_name()
   # TODO parent.animations.play(animation_name)
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


func process_input(_event: InputEvent) -> State:
   return null


func process_frame(_delta: float) -> State:
   return null


func process_physics(_delta: float) -> State:
   return null
