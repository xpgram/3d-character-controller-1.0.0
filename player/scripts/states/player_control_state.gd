class_name PlayerControlState
extends State

# TODO These are not generic.
#   Should PlayerState extend this one? Like, are these references useful to have?
@onready var player_model: SophiaSkin = %SophiaSkin
@onready var physics_properties: PhysicsProperties = %PhysicsProperties
@onready var ui_player_state_label: Label = %DebugOutput_PlayerState

var subject: CharacterBody3D
var camera: Camera3D

@warning_ignore('shadowed_variable')
func init(subject: CharacterBody3D, camera: Camera3D) -> void:
   self.subject = subject
   self.camera = camera


func enter() -> void:
   super.enter()

   # TODO Publish using an event bus instead?
   ui_player_state_label.text = get_state_name()
