extends State
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

const PlayerMovement = preload("uid://bc4pn1ojhofxm")


@export_group('Transition-to States', 'state_')
@export var state_idle: State
@export var state_move: State
@export var state_jump: State
@export var state_fall: State


@onready var camera: Camera3D = %Camera3D


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
   slide_timer.start()

   # Cut jump velocity immediately
   if subject.velocity.y > physics_properties.prop_move_min_jump_impulse:
      subject.velocity.y = physics_properties.prop_move_min_jump_impulse

   # Tween the ground plane velocities to 0.
   # TODO I feel like a tween isn't the right answer. I'll have to look this up, though.
   var tween_time := 1.0 / 3.0

   tween = create_tween()
   tween.set_loops(1)
   tween.set_parallel()

   # TODO These hard 0's are restrictive... Hm.
   #   Probably no way to do this without matching the wall's velocity.
   tween.tween_property(subject, 'velocity:x', 0, tween_time)
   tween.tween_property(subject, 'velocity:z', 0, tween_time)

   tween.play()


func on_exit() -> void:
   tween.kill()


func process_input(event: InputEvent) -> void:
   # TODO I don't move_and_slide() into the wall after entering this state, so
   #   this function call may have issues.
   var wall_normal := subject.get_wall_normal()
   var jump_vector := Vector2(wall_normal.x, wall_normal.z).normalized()

   var input_vector = Input.get_vector(
      'move_left',
      'move_right',
      'move_up',
      'move_down',
      0.4, # TODO This code block is frequent. There should be a consistent deadzone.
   )
   # TODO Apply camera vector to input_vector
   #   This is another common method. Probably needs to go into another utils library.

   # Implement wall jumps.
   if event.is_action_pressed('jump'):
      # Apply a push away from the wall to the subject's velocity.
      var wall_push_vector := jump_vector * physics_properties.prop_move_wall_jump_horizontal_impulse
      subject.velocity.x += wall_push_vector.x
      subject.velocity.z += wall_push_vector.y

      change_state.emit(state_jump)

   # TODO What happens when the input vector is (0,0)?
   var angle_to_wall_normal: float = abs(input_vector.angle_to(jump_vector))
   var pull_away_angle_limit: float = PI / 2

   # Implement pull away to disengage from the wall slide.
   if angle_to_wall_normal > pull_away_angle_limit:
      pull_away_timer.stop()
   elif pull_away_timer.is_stopped():
         pull_away_timer.start()


func process_physics(delta: float) -> void:
   if not tween.finished:
      subject.move_and_slide()
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

   subject.move_and_slide()


   if subject.is_on_floor():
      # TODO Instead of implementing Move, just save this for Landed.
      change_state.emit(state_idle)

   if not subject.is_on_wall():
      change_state.emit(state_fall)


func _on_slide_timeout() -> void:
   # TODO Add some small lateral push from the wall?
   change_state.emit(state_fall)


func _on_drift_away_timeout() -> void:
   # TODO Add some small lateral push from the wall, or just let fall.stick_move handle it?
   change_state.emit(state_fall)
