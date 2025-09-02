class_name CameraRigTrackController3D
extends CameraRigController3D
## A camera controller script that takes a child [Path3D] and a grandchild [PathFollow3D],
## and maps a [CameraRig3D]'s position to a point on that Path3D that is closest to the
## subject being followed.
##
## Note: the smaller the bake interval is for the given Path3D, the more work this script
## does to find the closest point.



# TODO Implement the track controller:
# - Find child Path3D and PathFollow3D
# - In operate_rig(),
#   - Take the Rig's subject's position.
#   - Iterate over all Path3D points, find the one with the least distance to subject.
#   - Get the normalized value: index / max_index
#   - Move the PathFollow3D's progress to the normalized value.
#   - Move the Rig accordingly to where the PathFollow3D is.
#     - Apply interpolation where appropriate.
#
# Optional:
# If the player can move faster than the camera somehow, they might trick the camera far
# enough away from its track that they can see stuff they shouldn't. So:
# - Ask Path3D which point is closest to the subject.
# - Calculate an ideal camera position.
#   - Lerp the camera to that ideal position.
#   - Ask Path3D which point is closest to this new lerped camera position.
#   - Warp to that Path3D point instead.
# - Wait, why not just lerp the PathFollow3D's progress value? Or its travel distance,
#   rather, so the length of the track doesn't affect speed.
#   - Main reason I can think of is that the camera would be confined to the track's baked
#     in values. We couldn't smoothly interpolate between them without letting the Rig do
#     _a little_ lerping.


# TODO Make CameraRig3D operable:
# I need to find a good balance for control. Camera controllers shouldn't need to get into
# the details of how lerping happens, they can just tell CameraRig3D what lerp speed
# they'd like. However, it'd be nice to just hand them the Rig entirely and say "do what-
# ever you want."
#
# So, proposal: CameraRig3D has a number of handles that describe common motions. E.g.:
# - rig_position: where the rig itself is located.
# - rig_rotation: how the rig itself is oriented.
# - pivot_rotation: controls the arm, and thus the camera's orbit.
# - arm_length: how far away the camera is from the rig's base.
# - focal_position: where the camera's point of interest is.
#
# These five controls should be enough to get us started. They represent the Rig's _ideal_
# configuration. Separately, the Rig also has a number of settings, like
# position_lerp_rate, that control how fast the camera moves to this ideal configuration.
# 
# The lerp settings on the Rig should have a toggle, I suppose. There may be times that
# the lerp may need to be more deliberately controlled by the script, such as lerping a
# PathFollow3D's travel_progress since it would be altogether easier to control.
#
# However... This would necessarily confine the camera's position to the baked-in path
# values. It would make its movements less smooth. Hm.