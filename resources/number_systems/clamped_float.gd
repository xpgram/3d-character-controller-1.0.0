@tool
class_name ClampedFloat
extends Resource
## A float value contained within a range. Can be interacted with directly or
## proportionally, and emits signals as its value changes. A useful encapsulation of
## structures like HP meters or stamina bars.


## Emitted when the direct value changes.
## `param direct_value` is the new direct value.
## `param translation` is the difference between the old value and the new one.
signal direct_value_changed(direct_value: float, translation: float)

## Emitted when the proportional value changes.
## `param proportional_value` is the new proportional value.
## `param translation` is the difference between the old value and the new one.
signal value_normal_changed(proportional_value: float, translation: float)

## Emitted when the minimum range value changes.
signal min_value_changed(value: float)

## Emitted when the maximum range value changes.
signal max_value_changed(value: float)

## Emitted when the direct value is equal to the minimum range.
signal meter_empty()

## Emitted when the direct value is equal to the maximum range.
signal meter_full()

## Emitted when the direct value crosses some defined threshhold in
## `property direct_value_threshholds`.
signal meter_met_value(threshhold: float, value: float)

## Emitted when the proportional value crosses some defined threshhold in
## `property proportional_value_threshholds`.
signal meter_met_proportion(threshhold: float, value_normal: float)


## The actual value of this clamped float.
@export var direct_value: float = 0:
   set(value):
      var old_direct_value := direct_value
      direct_value = clampf(value, min_direct_value, max_direct_value)
      direct_value_changed.emit(direct_value, direct_value - old_direct_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true
         _set_proportional_to_direct_value()
         _disable_recursive_property_editing = false

      _emit_direct_value_threshholds(direct_value, old_direct_value)

## The proportional value of this clamped float (between 0.0 and 1.0).
@export var proportional_value: float = 0:
   set(value):
      var old_proportional_value := proportional_value
      proportional_value = clampf(value, 0.0, 1.0)
      value_normal_changed.emit(proportional_value, proportional_value - old_proportional_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true
         _set_direct_value_to_proportional()
         _disable_recursive_property_editing = false

      _emit_proportional_value_threshholds(proportional_value, old_proportional_value)


## The minimum value for this range.
@export_range(0, 100, 0.1, 'or_greater; hide_slider') var min_direct_value: float = 0:
   set(value):
      min_direct_value = value
      min_value_changed.emit(min_direct_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true

         if min_direct_value > max_direct_value:
            max_direct_value = min_direct_value
         if min_direct_value > direct_value:
            direct_value = min_direct_value

         _disable_recursive_property_editing = false


## The maximum value for this range.
@export_range(0, 100, 0.1, 'or_greater; hide_slider') var max_direct_value: float = 100:
   set(value):
      max_direct_value = value
      max_value_changed.emit(max_direct_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true

         if max_direct_value < min_direct_value:
            min_direct_value = max_direct_value
         if max_direct_value < direct_value:
            direct_value = max_direct_value
            
         _disable_recursive_property_editing = false

@export_subgroup('Value threshholds')

## A list of threshhold values for which `signal meter_met_value` will be emitted when the
## direct value's translation vector intersects with the threshhold.
@export var direct_value_threshholds: PackedFloat32Array = []

@export_subgroup('Proportional value threshholds')

## A list of threshhold values for which `signal meter_met_proportion` will be emitted
## when the proportional value's translation vector intersects with the threshhold.
@export var proportional_value_threshholds: PackedFloat32Array = []


# FIXME Is there a way to do this without a side-effect?
## If true, then properties like `proportional_value` being updated should not also update
## other properties, such as `direct_value`. Useful for updating the editor's config
## display without triggering an infinite recursion.
var _disable_recursive_property_editing := false


func _init() -> void:
   direct_value = min_direct_value
   max_direct_value = max_direct_value if max_direct_value >= min_direct_value else min_direct_value


## Emits signals when the direct value changes to or beyond set threshhold targets.
## Only emits a signal for one `direct_value_threshhold` at a time: the one whose value is
## closest to `param new_value`.
## Also emits signals for `meter_empty` and `meter_full`, regardless of any other
## threshhold targets emitted.
func _emit_direct_value_threshholds(new_value: float, old_value: float) -> void:
   if is_equal_approx(new_value, min_direct_value):
      meter_empty.emit()
   if is_equal_approx(new_value, max_direct_value):
      meter_full.emit()

   var met_threshholds := _get_threshholds_met(direct_value_threshholds, new_value, old_value)

   if len(met_threshholds) == 0:
      return

   var closest_threshhold := _get_closest_threshhold(met_threshholds, new_value)
   meter_met_value.emit(closest_threshhold, new_value)


## Emits signals when the proportional value changes to or beyond set threshhold targets.
## Only emits a signal for one `proportional_value_threshhold` at a time: the one whose
## value is closest to `param new_value`.
func _emit_proportional_value_threshholds(new_value: float, old_value: float) -> void:
   var met_threshholds := _get_threshholds_met(proportional_value_threshholds, new_value, old_value)

   if len(met_threshholds) == 0:
      return

   var closest_threshhold := _get_closest_threshhold(met_threshholds, new_value)
   meter_met_proportion.emit(closest_threshhold, new_value)


## Given a list of threshhold numbers, returns a list of threshhold numbers within the
## range defined by new_value and old_value.
func _get_threshholds_met(threshholds: Array[float], new_value: float, old_value: float) -> Array[float]:
   return threshholds.filter(
      func (threshhold):
         # If old_value is equal to threshhold, return false since this threshhold was
         # already met previously.
         return false if is_equal_approx(old_value, threshhold) \
            else sign(threshhold - new_value) != sign(threshhold - old_value)
   )


## Given a list of threshhold numbers, returns the threshhold with the least distance to
## the given value.
func _get_closest_threshhold(threshholds: Array[float], value: float) -> float:
   assert(not threshholds.is_empty(), '_get_closest_threshhold() must be given a list of 1 or more points.')

   return threshholds.reduce(
      func (closest, threshhold):
         var threshhold_distance: float = abs(threshhold - value)
         var closest_distance: float = abs(closest - value)
         return threshhold if threshhold_distance < closest_distance else closest
   )


## Returns the width of the range as a float.
func _get_range() -> float:
   return max_direct_value - min_direct_value


## Sets the proportional value to a number reflecting the current direct value.
## In the rare case that `min_direct_value == max_direct_value`, the proportional value
## will be set to 1.0.
func _set_proportional_to_direct_value() -> void:
   var value_range := _get_range()
   proportional_value = (
      1.0 if is_equal_approx(value_range, 0.0)
      else (direct_value - min_direct_value) / value_range
   )


## Sets the direct value to a number reflecting the current proportional value.
func _set_direct_value_to_proportional() -> void:
   direct_value = (proportional_value * _get_range()) + min_direct_value
