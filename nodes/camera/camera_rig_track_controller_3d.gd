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

## The distance above and below the curve that is considered a valid camera position.
## The orientation of this plane, the up and down directions, are taken from the basis
## vectors of the `property perspective_node`.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var plane_height := 0.0

## Whether the curve's tilt number controls the tilt of the camera plane's up direction
## instead of the tilt for the camera itself.
## This value does not prevent [Curve3D] tilt from angling the camera perspective.
@export
var tilt_controls_plane := false

# TODO Left and right side flare-outs.
#  An inverse bevel to aid in blending smaller boxes into larger ones.
#  NOTE: Experiment with sharp corners first to see if this is even necessary.
#   If the player is traveling slowly, it shouldn't be.
#   If the player is fast, then lerping the camera ought to create this effect anyway.
#   Funnel-like rooms should probably just have a large box anyway. The camera is always
#     clamped by the subject's actual range of movement.
# TODO Save these settings as a resource?
#  So I can save and modify a standard "hallway_dimensions.tres" or some such.


func setup_initial_rig_conditions(camera_rig: CameraRig3D) -> void:
   var subject_position := _get_camera_rig_subject_local_position(camera_rig)
   var closest_offset := track.curve.get_closest_offset(subject_position)

   trackball.progress = closest_offset

   camera_rig.global_position = perspective_node.global_position
   camera_rig.global_rotation = perspective_node.global_rotation


func operate_rig(delta: float, camera_rig: CameraRig3D) -> void:
   var subject_position := _get_camera_rig_subject_local_position(camera_rig)
   var increment := _get_tipping_direction(subject_position)

   if increment != 0:
      trackball.progress = _get_closest_curve_progress(subject_position, increment)
   
   var vertical_vector = _get_vertical_vector_at_curve_progress(subject_position, trackball.progress)

   # Assign new camera transform values.
   camera_rig.global_position = CameraUtils.lerp_position(
      camera_rig.global_position,
      perspective_node.global_position + vertical_vector,
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


## From a point on the curve at `param curve_progress`, return the nearest point to
## `param subject_position` on its local vertical axis.
func _get_vertical_vector_at_curve_progress(subject_position: Vector3, curve_progress: float) -> Vector3:
   if plane_height == 0.0:
      return Vector3.ZERO

   var sampled_transform := track.curve.sample_baked_with_rotation(
      curve_progress,
      trackball.cubic_interp,
      tilt_controls_plane,
   )
   var forward_vector := sampled_transform.basis.z
   var rightward_vector := sampled_transform.basis.x

   # From a point on the curve, get a point on its local vertical axis.
   var vertical_vector := subject_position - sampled_transform.origin
   vertical_vector = vertical_vector.slide(forward_vector)
   vertical_vector = vertical_vector.slide(rightward_vector)

   # Cap the point to the length limit. The vector's distance along the vertical axis can
   # be positive or negative, so we use half the plane height.
   vertical_vector = vertical_vector.limit_length(plane_height * 0.5)

   return vertical_vector


## Returns the distance to `param subject_position` for a point on the [Curve3D] as
## determined by `param progress` along the curve.
func _get_distance_to_subject(subject_position: Vector3, progress: float) -> float:
   return track.curve.sample_baked(progress, trackball.cubic_interp).distance_to(subject_position)
