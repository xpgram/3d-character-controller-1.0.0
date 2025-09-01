extends Node

@warning_ignore_start('UNUSED_SIGNAL')

signal camera_region_entered(entered_by: CameraTarget3D, region: CameraRegion3D)
signal camera_region_exited(exited_by: CameraTarget3D, region: CameraRegion3D)

signal kill_plane_touched(body: PhysicsBody3D)
signal flag_reached
