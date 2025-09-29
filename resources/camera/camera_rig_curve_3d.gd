@tool
class_name CameraRigCurve3D
extends Resource
## A resource used to extend a [Curve3D] with other camera-rig–specific values to
## interpolate.

## IMPLEMENT:
## [x] [CameraRigCurvePoint3D] has the same properties as [Curve3D] points do.
## [ ] A [Curve3D] is built from the [CameraRigCurvePoint3D]'s.
## [ ] This [Curve3D] is passed into a [Path3D] somehow.
## [ ] The progress value of a [PathFollow3D] is used to determine which two
##     [CameraRigCurvePoint3D]'s it is sitting between.
## [ ] The progress value and those two camera points are used to interpolate linearly the
##     other camera transforms and settings.

## IMPLEMENT (other):
## [ ] The resulting [Curve3D] can be seen in the 3D view.
##     I don't think this one is possible. Not simply.
##     It might make more sense to add a [Curve3D] directly, and via a @tool, extend the
##     number of points it has to a seperate, parallel list with the other camera values.
##     Worst to worst, this may have the side-effect of losing information every time you
##     add, remove or change the order of the [Curve3D]'s points, but it may still be
##     workable.

## 
@export var points: Array[CameraRigCurvePoint3D] = []:
   get():
      return points
   set(new_points):
      var points_no_null := new_points.map(func (curve_point):
         return curve_point if curve_point else CameraRigCurvePoint3D.new()
      )
      points.assign(points_no_null)


##
func _init() -> void:
   # TODO Pass point values to a Curve3D.
   pass


##
func get_point(idx: int) -> CameraRigCurvePoint3D:
   return points.get(idx)
