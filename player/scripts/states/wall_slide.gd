extends PlayerControlState
# TODO Extend from PlayerState instead of State?
#   State > PlayerState > Wall_Slide
#    ^ Includes State structure stuff
#            ^ Includes Player specific stuff, like Camera and PhysicsProperties
#                          ^ Includes State behavior

# - Clamp velocity up and down
#   - down should feel the wall friction
#   - up should as well, but I'm not sure when/how that'll come up
#   - clamp should be like a lerp, btw: not instantaneous
# - Set timer
#   - Timer elapsed: transition to normal fall
#     (but disallow a 2nd wall slide... how?)
# - Player distances from wall: transition to normal fall


@export_group('Transition-to States', 'state_')
@export var state_landed: PlayerControlState
@export var state_jump: PlayerControlState
@export var state_fall: PlayerControlState


# @onready var camera: Camera3D = %Camera3D


var tween: Tween

## The maximum time the player can slide for.
var slide_timer: Timer = Timer.new()

## How long the player must hold the stick away from the wall before Wall Slide terminates.
var pull_away_timer: Timer = Timer.new()


func _ready() -> void:
   slide_timer.one_shot = true
   slide_timer.wait_time = physics_properties.prop_move_wall_slide_max_time
   slide_timer.timeout.connect(_on_slide_timeout)
   add_child(slide_timer)

   pull_away_timer.one_shot = true
   pull_away_timer.wait_time = physics_properties.prop_move_wall_slide_pull_away_time
   pull_away_timer.timeout.connect(_on_drift_away_timeout)
   add_child(pull_away_timer)


func on_enter() -> void:
   # Animate player wall slide
   player_model.wall_slide()
   var wall_normal := subject.get_wall_normal()
   var wall_normal_2D = Vector2(wall_normal.x, wall_normal.z)
   var y_rotation_matching_wall := -Vector2.UP.angle_to(wall_normal_2D)
   player_model.rotation.y = y_rotation_matching_wall

   slide_timer.start()

   # Cut jump velocity immediately
   if subject.velocity.y > physics_properties.prop_move_min_jump_impulse:
      subject.velocity.y = physics_properties.prop_move_min_jump_impulse

   # Tween the ground plane velocities to 0.
   # TODO I feel like a tween isn't the right answer. I'll have to look this up, though.
   #   I need something more like an elastic number. It's fine as it's smaller, but it
   #   rebounds with built potential energy as it reaches farther and farther away.
   var tween_time := 1.0 / 2.0 # TODO Describe in a properties node.

   tween = create_tween()
   tween.set_loops(1)
   tween.set_ease(Tween.EASE_OUT)

   # TODO These values are hard limits. What if the wall were moving?
   var wall_slide_lateral_speed := 0.0 # TODO This should be in physics_properties
   # TODO Remove if we don't need this.
   # var ideal_ground_velocity := Vector2(
   #    clampf(subject.velocity.x, -wall_slide_lateral_speed, wall_slide_lateral_speed),
   #    clampf(subject.velocity.z, -wall_slide_lateral_speed, wall_slide_lateral_speed),
   # )

   tween.set_parallel()
   tween.tween_property(subject, 'velocity:x', wall_slide_lateral_speed, tween_time)
   tween.tween_property(subject, 'velocity:z', wall_slide_lateral_speed, tween_time)

   tween.play()


func on_exit() -> void:
   tween.kill()


func process_input(event: InputEvent) -> void:
   # TODO I don't move_and_slide() into the wall after entering this state, so
   #   this function call may have issues.
   var wall_normal := subject.get_wall_normal().slide(Vector3.UP).normalized()

   var movement_vector := InputUtils.get_movement_vector(camera.global_basis)

   # Implement wall jumps.
   if event.is_action_pressed('jump'):
      # Apply a push away from the wall to the subject's velocity.
      var wall_push_vector := wall_normal * physics_properties.prop_move_wall_jump_horizontal_impulse
      subject.velocity.x += wall_push_vector.x
      subject.velocity.z += wall_push_vector.z

      request_state_change(state_jump)

   # TODO What happens when the input vector is (0,0)?
   var angle_to_wall_normal: float = abs(movement_vector.angle_to(movement_vector))
   var pull_away_angle_limit: float = PI / 2

   # Implement pull away to disengage from the wall slide.
   if angle_to_wall_normal > pull_away_angle_limit:
      pull_away_timer.stop()
   elif pull_away_timer.is_stopped():
         pull_away_timer.start()


func process_physics(delta: float) -> void:
   if not tween.finished:
      return

   # TODO How to apply friction?
   #   gravity needs to be stronger when above 0, and weaker when below it.
   #   Is clampf()ing our velocity enough?
   var friction_modifier := physics_properties.prop_move_wall_slide_friction

   subject.velocity.y -= physics_properties.prop_physics_gravity * delta

   subject.velocity.y = clampf(
      subject.velocity.y,
      -physics_properties.prop_move_wall_slide_max_velocity,
      physics_properties.prop_move_wall_slide_max_velocity,
   )


func post_physics_check() -> void:
   if subject.is_on_floor():
      request_state_change(state_landed)

   elif not subject.is_on_wall():
      request_state_change(state_fall)


func _on_slide_timeout() -> void:
   # TODO Add some small lateral push from the wall?
   request_state_change(state_fall)


func _on_drift_away_timeout() -> void:
   # TODO Add some small lateral push from the wall, or just let fall.stick_move handle it?
   request_state_change(state_fall)
