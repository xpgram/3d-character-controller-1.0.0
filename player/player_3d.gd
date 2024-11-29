extends CharacterBody3D
## Handles player character behaviors.

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 30.0
@export var stopping_speed := 2.0
@export var rotation_speed := 15.0
@export var jump_impulse := 12.0
@export var min_jump_impulse := 4.0

var _last_movement_direction := Vector3.BACK

var _gravity := -30.0

@onready var _camera: Camera3D = %Camera3D
@onready var _character_model: SophiaSkin = %SophiaSkin


func _physics_process(delta: float) -> void:
   _move_character_body(delta)

   # Animation steps
   _rotate_character_body(delta)
   _update_animation_state()


## Handle character movement input.
func _move_character_body(delta: float) -> void:
   _apply_gravity(delta)
   _handle_movement_input(delta)
   _handle_jump_input()

   move_and_slide()


## Manages character fall behavior.
func _apply_gravity(delta: float) -> void:
   velocity.y += _gravity * delta


## Manages character lateral (ground plane) movement.
func _handle_movement_input(delta: float) -> void:
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
   # Normalize the camera-angled movement vector onto the ground plane.
   move_direction = move_direction.normalized() * curved_input.length()

   # Calculate new velocity for this frame.
   var lateral_velocity := Vector3(velocity.x, 0, velocity.z)
   var new_velocity = lateral_velocity.move_toward(move_direction * move_speed, acceleration * delta)

   var user_input_is_none := is_zero_approx(move_direction.length())
   var velocity_in_dime_stop_range := new_velocity.length() < stopping_speed

   if user_input_is_none and velocity_in_dime_stop_range:
      new_velocity = Vector3.ZERO

   # Move the character
   velocity.x = new_velocity.x
   velocity.z = new_velocity.z

   # Store the last input direction
   if move_direction.length() > 0:
      _last_movement_direction = move_direction


## Manages character jump behavior.
func _handle_jump_input() -> void:
   var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
   var is_ending_jump := Input.is_action_just_released("jump") and velocity.y > min_jump_impulse

   if is_starting_jump:
      velocity.y += jump_impulse

   if is_ending_jump:
      velocity.y = min_jump_impulse


# TODO Accept an argument instead of depending on script-globals?
## Rotates the character body into the direction of travel.
func _rotate_character_body(delta: float) -> void:
   var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)

   # Smoothly rotate to the direction of travel.
   _character_model.rotation.y = lerp_angle(
         _character_model.rotation.y,
         target_angle,
         rotation_speed * _last_movement_direction.length() * delta
   )


## Update animation state to reflect new input values.
func _update_animation_state() -> void:
   var is_starting_jump := Input.is_action_just_pressed("jump") and velocity.y > 0
   var is_falling := not is_on_floor() and velocity.y < 0
   var ground_speed := velocity.length()

   if is_starting_jump:
      _character_model.jump()
   elif is_falling:
      _character_model.fall()
   elif is_on_floor() and ground_speed > 0.0:
      _character_model.move()
   elif is_on_floor():
      _character_model.idle()
