class_name PlayerControlState
extends State

# TODO These imports carry over to all inheritors. Is that what I want?
#   i.e. I can't reimport these. InputUtils is a variable that's already defined.
#   I've never written code that wanted me to use invisible values so much.
const InputUtils = preload('uid://tl2nnbstems3')
const MovementUtils = preload('uid://bc4pn1ojhofxm')

var subject: CharacterBody3D
var camera: Camera3D

@onready var player_model: SophiaSkin = %SophiaSkin
@onready var physics_properties: PhysicsProperties = %PhysicsProperties
@onready var ui_player_state_label: Label = %DebugOutput_PlayerState


## Call to initialize this [PlayerControlState] before using it.
@warning_ignore('shadowed_variable')
func init(subject: CharacterBody3D, camera: Camera3D) -> void:
   self.subject = subject
   self.camera = camera


func enter() -> void:
   super.enter()

   # TODO Publish using an event bus instead?
   ui_player_state_label.text = get_state_name()


func process_physics_machine_hook(delta: float) -> void:
   super.process_physics_machine_hook(delta)
   subject.move_and_slide()


func process_world_physics(delta: float) -> void:
   MovementUtils.apply_gravity(
      delta,
      subject,
      physics_properties.prop_physics_gravity,
      Vector3.UP,
   )
