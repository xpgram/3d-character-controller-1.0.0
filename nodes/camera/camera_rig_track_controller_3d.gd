@tool
class_name CameraRigTrackController3D
extends CameraRigController3D
## A camera controller script that takes a child [Path3D] and a grandchild [PathFollow3D],
## and moves the PathFollow3D along the Path3D to minimize the distance between itself and
## a [CameraRig3D]'s subject. This "elastic band" system can be thought of as pulling a
## track ball along a course via a string.
## 
## This does mean that curves in the Path3D as it relates to subject position may result
## in local minima that the track ball may have difficulty getting out of.


# TODO Implement the track controller:
# Init:
#  - Since a place on the Path3D is not known:
#    - Check all baked-in points for distance to subject.
#      - (Optional) Check the Path3D bezier points first to narrow down the range.
#    - Pick the point with the shortest distance and align the camera.
#      Use a transition, if you like. (Instant warp, lerp, fade out/in, etc.)
#    - Save the point indice we picked, unless it's easy to figure out.
# Update step:
#  - Check the left and right adjacent Path3D points for distance.
#  - If one is shorter than the current point, continue checking points in that
#     direction until the distance increases from the last point checked.
#  - This is your minimum distance to subject, and represents the new ideal camera
#     position.
#  - Lerp the track ball from its current point to the desired one.
#    - travel_distance should be fine here, because I think Path3D allows this number to
#       represent sub-pixel travel, i.e., I can describe distances between baked points
#       and it will just pick the nearest one.
#  - Use this new point to pick a pair of points: one closer to the target, one further
#     away. This describes the subinterval range.
#  - Using the Path3D's distance interval, find the remainder of the travel distance.
#  - Using {remainder / interval}, get a normalized value for progress along the
#     subinterval range.
#  - Align the camera with whichever point was picked via lerp.
#  - And finally, lerp the camera's position along the vector containing the distance
#     remainder using the calculated subinterval range value.

## The distance in 3D units used to determine which direction along the track the
## trackball must slide to maintain the shortest distance it can to its target.
## Local minima within distances smaller than this number may not be detected by the
## elastic-band system, but smaller numbers also demand much more work.
@export_range(0.0, 0.5, 0.01, 'or_greater') var tipping_distance := 0.05

## A Path3D representing the track the camera rig should follow.
@onready var track: Path3D = $Track

## A PathFollow3D to track position along the camera track.
@onready var trackball: PathFollow3D = $Track/TrackBall


func _get_configuration_warnings() -> PackedStringArray:
   var warnings: PackedStringArray = []

   var track_node: Node = $Track
   var ball_node: Node = $Track/TrackBall

   if track_node is not Path3D:
      warnings.append('This rig controller is missing a node at \'$Track\' of type Path3D.')
   if ball_node is not PathFollow3D:
      warnings.append('This rig controller is missing a node at \'$Track/TrackBall\' of type PathFollow3D.')

   return warnings


func setup_initial_rig_conditions(camera_rig: CameraRig3D) -> void:
   var subject_position := _get_camera_rig_subject_local_position(camera_rig)
   var closest_offset := track.curve.get_closest_offset(subject_position) # TODO What is an 'offset'?

   trackball.progress = closest_offset
   
   camera_rig.position = trackball.position
   camera_rig.rotation = trackball.rotation


# TODO Break these into several helper functions.
func operate_rig(delta: float, camera_rig: CameraRig3D) -> void:
   var subject_position := _get_camera_rig_subject_local_position(camera_rig)

   # Determine which direction to move along the curve in.
   # TODO This block can be cleaned up, surely.
   var z_distance := trackball.position.distance_to(subject_position)
   var p_distance := track.curve \
      .sample_baked(trackball.progress + tipping_distance, trackball.cubic_interp) \
      .distance_to(subject_position)
   var n_distance := track.curve \
      .sample_baked(trackball.progress - tipping_distance, trackball.cubic_interp) \
      .distance_to(subject_position)

   if z_distance < p_distance and z_distance < n_distance:
      return # Quit early: we're already at the closest position.

   var increment := tipping_distance if p_distance < n_distance else -tipping_distance

   # Iterate over the curve until we find a local minima.
   var progress := trackball.progress
   var next_progress := progress + increment

   var next_is_shorter := func (a: float, b: float) -> bool:
      var a_dist := track.curve.sample_baked(a, trackball.cubic_interp).distance_to(subject_position)
      var b_dist := track.curve.sample_baked(b, trackball.cubic_interp).distance_to(subject_position)
      return b_dist < a_dist

   while next_is_shorter.call(progress, next_progress):
      progress = next_progress
      next_progress += increment

   # Lerp the trackball to the new progress value.
   trackball.progress = lerpf(trackball.progress, progress, 6.0 * delta)

   # Set camera position.
   camera_rig.position = trackball.global_position

   var new_rotation = trackball.global_rotation
   new_rotation.x = 0.0
   new_rotation.z = 0.0
   new_rotation.y -= PI / 2
   camera_rig.rotation = new_rotation


## Returns a [Vector3] for the camera rig's subject's transform position in the camera
## track's local space. If the camera rig has no subject, then it uses the camera rig's
## transform position.
func _get_camera_rig_subject_local_position(camera_rig: CameraRig3D) -> Vector3:
   var subject_position := camera_rig.subject.global_position if camera_rig.subject \
      else camera_rig.global_position
   return track.to_local(subject_position)
