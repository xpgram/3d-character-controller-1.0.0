class_name State
extends Node

@export var animation_name: String


@onready var physics_properties := %PhysicsProperties
@onready var ui_player_state_label := %DebugOutput_PlayerState


var parent: Player


func get_state_name() -> String:
   return "Player state: " + name


func enter() -> void:
   ui_player_state_label.text = get_state_name()
   # parent.animations.play(animation_name)


func exit() -> void:
   pass


func process_input(_event: InputEvent) -> State:
   return null


func process_frame(_delta: float) -> State:
   return null


func process_physics(_delta: float) -> State:
   return null
