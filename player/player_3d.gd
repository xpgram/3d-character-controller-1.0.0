extends CharacterBody3D
## Handles player character behaviors.

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 30.0
@export var rotation_speed := 15.0

var _last_movement_direction := Vector3.BACK

@onready var _camera: Camera3D = %Camera3D
@onready var _character_model: SophiaSkin = %SophiaSkin


func _physics_process(delta: float) -> void:
   _move_character_body(delta)

   # Animation steps
   _angle_character_body(delta)
   _update_animation_state()


## Handle character movement input.
func _move_character_body(delta: float) -> void:
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
   # Normalize the camera-angled movement vector onto the ground plane.
   move_direction = move_direction.normalized() * curved_input.length()

   # Move the character
   velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
   move_and_slide()

   # Store the last input direction
   if move_direction.length() > 0:
      _last_movement_direction = move_direction


# TODO Accept an argument instead of depending on script-globals?
## Rotates the character body into the direction of travel.
func _angle_character_body(delta: float) -> void:
   var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)

   # Smoothly rotate to the direction of travel.
   _character_model.rotation.y = lerp_angle(
         _character_model.rotation.y,
         target_angle,
         rotation_speed * _last_movement_direction.length() * delta
   )


func _update_animation_state() -> void:
   var ground_speed := velocity.length()

   if ground_speed > 0.0:
      _character_model.move()
   else:
      _character_model.idle()
