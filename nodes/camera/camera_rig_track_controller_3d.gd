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
