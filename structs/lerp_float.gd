class_name LerpFloat
## Intended to reduce boilerplate for lerped values.
## TODO I'm not convinced I need this very small class yet, though tilt_camera nearly had
##  like 5 or 6 values to animate, which did nearly push me over the edge.


## The actual value of this float.
var actual_value := 0.0

## The value to be animated toward.
var target_value := 0.0


## Given a weight, lerp this float's actual value to its target value. Will not move
## beyond the target.
func lerp(weight: float) -> void:
   weight = clampf(weight, 0, 1)
   actual_value = lerpf(actual_value, target_value, weight)


## Finish animating by instantly setting the actual value to the target value.
func finish() -> void:
   actual_value = target_value


## Set a new value to both the actual and target values of this float.
func set_as_finished(value: float) -> void:
   target_value = value
   finish()
