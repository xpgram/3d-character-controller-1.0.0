class_name CameraRigTrackController3D
extends CameraRigController3D
## A camera controller script that takes a child [Path3D] and a grandchild [PathFollow3D],
## and moves the PathFollow3D along the Path3D to minimize the distance between itself and
## a [CameraRig3D]'s subject over short distances of the curve, not unlike pulling a track
## ball along a course via a string.
## 
## This strategy does mean that curves in the Path3D as it relates to subject position may
## result in local minima that the track ball may have difficulty getting out of.


const CameraUtils = preload('uid://bj6uktkk7o67b')


## A [Path3D] representing the track the camera rig should follow.
@export var track: Path3D

## A [PathFollow3D] to track position along the camera track.
@export var trackball: PathFollow3D

## A [Node3D] describing the camera rig's orientation at the point along the curve the
## trackball is located.
@export var perspective_node: Node3D

## The distance in 3D units used to determine which direction along the track the
## trackball must slide to maintain the shortest distance it can to its target.
## Local minima within distances smaller than this number may not be detected by the
## elastic-band system, but smaller numbers also demand much more work.
@export_range(0.0, 0.5, 0.01, 'or_greater') var tipping_distance := 0.05

@export_group('Curved Plane Settings')

## The up direction for the curve's plane orientation.
##
## Only the perpendicular component to the curve will be used to determine the up
## direction, and specifically defines the orientation for the point at `progress == 0.0`;
## this direction will rotate as the curve does to maintain a consistent box width.
##
## *WARNING:* This value should not be parallel to the curve at `progress == 0.0`.
@export
var up_direction := Vector3.UP

## The distance above the curve that is considered a valid camera position.
## 'Above' is determined via `property up_direction`.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var height_above_curve := 0.0

## The distance below the curve that is considered a valid camera position.
## 'Below' is determined via `property up_direction`.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var height_below_curve := 0.0

## Whether the curve's tilt number controls the tilt of the camera plane's up direction
## instead of the tilt for the camera itself.
@export
var tilt_controls_plane := false

# TODO If height above == below == 0.0, skip box related operations. Or at least make them
#  unnoticeable.
# TODO Pseudo code:
#  Get subject's nearest curve offset.
#  Determine Up dimension.
#  Get nearest point along Up dimension.
#  Clamp to range defined by height above and below.
#  This is your plane position.
# TODO Plane curves with track curve.
#  Height is always a distance perpendicular to the curve, in the direction of up_dir.
#  Using the PathFollow's forward basis, slide the up_dir and normalize: this is the
#  progress-relative up_dir.
#  In case PathFollow rotation mode isn't XYZ, use curve.sample_baked_with_rotation()
#  instead.
# TODO Left and right side flare-outs.
#  An inverse bevel to aid in blending smaller boxes into larger ones.
#  NOTE: Experiment with sharp corners first to see if this is even necessary.
#   If the player is traveling slowly, it shouldn't be.
#   If the player is fast, then lerping the camera ought to create this effect anyway.
#   Funnel-like rooms should probably just have a large box anyway. The camera is always
#     clamped by the subject's actual range of movement.


func setup_initial_rig_conditions(camera_rig: CameraRig3D) -> void:
   var subject_position := _get_camera_rig_subject_local_position(camera_rig)
   var closest_offset := track.curve.get_closest_offset(subject_position)

   trackball.progress = closest_offset
   
   # TODO Setup initial conditions sets a lerp target, not an instant transition.
   #  skip_animation() sets an instant transition.
   #  These should be controllable by on_enter() and on_resume().
   #  on_enter() should still be called if a region with the same priority is resumed, yes?
   camera_rig.global_position = perspective_node.global_position
   camera_rig.global_rotation = perspective_node.global_rotation


func operate_rig(delta: float, camera_rig: CameraRig3D) -> void:
   var subject_position := _get_camera_rig_subject_local_position(camera_rig)
   var increment := _get_tipping_direction(subject_position)

   if increment != 0:
      trackball.progress = _get_closest_curve_progress(subject_position, increment)

   # Assign new camera transform values.
   camera_rig.global_position = CameraUtils.lerp_position(
      camera_rig.global_position,
      perspective_node.global_position,
      Constants_Player.CAMERA_GROUND_LERP_RATE * delta,
      Constants_Player.CAMERA_VERTICAL_LERP_RATE * delta,
   )
   camera_rig.global_rotation = CameraUtils.lerp_rotation(
      camera_rig.global_rotation,
      perspective_node.global_rotation,
      Constants_Player.CAMERA_GROUND_LERP_RATE * delta,
   )


## Returns a [Vector3] for the camera rig's subject's transform position in the camera
## track's local space. If the camera rig has no subject, then it uses the camera rig's
## transform position.
func _get_camera_rig_subject_local_position(camera_rig: CameraRig3D) -> Vector3:
   var subject_position := camera_rig.subject.global_position if camera_rig.subject \
      else camera_rig.global_position
   subject_position = track.to_local(subject_position)
   subject_position += Vector3.UP * 4 # TODO In place of any kind of displacement thing for now.
   return subject_position


## Return a signed number (1, 0, or -1) representing which direction of the [Curve3D] has
## a steeper incline toward the given `param subject_position`.
func _get_tipping_direction(subject_position: Vector3) -> float:
   var current_distance := trackball.position.distance_to(subject_position)

   var positive_dir_distance := track.curve \
      .sample_baked(trackball.progress + tipping_distance, trackball.cubic_interp) \
      .distance_to(subject_position)
   var negative_dir_distance := track.curve \
      .sample_baked(trackball.progress - tipping_distance, trackball.cubic_interp) \
      .distance_to(subject_position)

   if current_distance <= negative_dir_distance and current_distance <= positive_dir_distance:
      return 0

   return tipping_distance if positive_dir_distance < negative_dir_distance else -tipping_distance


## Iterates from the current curve progress in the direction of `param increment` to find
## a new progress value with the closest distance to `param subject_position`.
## If `param increment` is zero, the current curve progress will be returned.
func _get_closest_curve_progress(subject_position: Vector3, increment: float) -> float:
   if is_zero_approx(increment):
      return trackball.progress

   var progress := trackball.progress
   var next_progress := progress + increment

   var progress_distance := _get_distance_to_subject(subject_position, progress)
   var next_progress_distance := _get_distance_to_subject(subject_position, next_progress)

   while next_progress_distance < progress_distance:
      progress = next_progress
      next_progress += increment

      progress_distance = next_progress_distance
      next_progress_distance = _get_distance_to_subject(subject_position, next_progress)

   return progress


## Returns the distance to `param subject_position` for a point on the [Curve3D] as
## determined by `param progress` along the curve.
func _get_distance_to_subject(subject_position: Vector3, progress: float) -> float:
   return track.curve.sample_baked(progress, trackball.cubic_interp).distance_to(subject_position)
