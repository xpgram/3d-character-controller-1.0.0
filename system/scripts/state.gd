class_name State
extends Node

@warning_ignore('UNUSED_SIGNAL')
signal change_state(new_state: State)


@export var animation_name: String


# TODO These are not generic.
@onready var physics_properties := %PhysicsProperties
@onready var ui_player_state_label := %DebugOutput_PlayerState


# TODO Use a template type instead of CharacterBody.
var subject: CharacterBody3D


func get_state_name() -> String:
   # TODO This also isn't generic.
   return "Player state: " + name


@warning_ignore('shadowed_variable')
func init(subject: CharacterBody3D) -> void:
   self.subject = subject


## Handle the State startup process.
func enter() -> void:
   ui_player_state_label.text = get_state_name()
   # TODO subject.animations.play(animation_name)
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
