class_name CameraRigTetherController3D
extends CameraRigController3D
## A camera controller script that takes a child [Path3D] and a grandchild [PathFollow3D],
## and maps a [CameraRig3D]'s position to a point on that Path3D via an "elastic band"
## system. That is, it treats the PathFollow3D as a track ball tethered to the camera's
## subject, and it moves that track ball so as to minimize the elastic band's length.
## 
## This is effective for curvy track paths where the subject's position might be near
## several parts of the track's length, but maintaining a preference for where the track
## ball is now is desirable.
