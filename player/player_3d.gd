extends CharacterBody3D
## Handles player character behaviors.

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 30.0

@onready var _camera: Camera3D = %Camera3D


func _physics_process(delta: float) -> void:
   _move_character_body(delta)


func _move_character_body(delta: float) -> void:
   ## Handle character movement input.
   var raw_input := Input.get_vector(
         "move_left",
         "move_right",
         "move_up",
         "move_down",
         0.4
   )
   # This step squares the "strength" of the input vector, allowing finer control near the
   # lower end of the range.
   var curved_input := raw_input * raw_input.length()

   var forward_vector := _camera.global_basis.z
   var rightward_vector := _camera.global_basis.x

   var move_direction := (
         forward_vector * curved_input.y
         + rightward_vector * curved_input.x
   )
   # Prevent movement up or into the ground.
   move_direction.y = 0.0

   velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
   move_and_slide()
