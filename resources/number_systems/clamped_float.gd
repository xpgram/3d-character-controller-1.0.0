@tool
class_name ClampedFloat
extends Resource
## A float value contained within a range. Can be interacted with directly or
## proportionally, and emits signals as its value changes. A useful encapsulation of
## structures like HP meters or stamina bars.


## Emitted when the real number value changes.
## `param value` is the new value.
## `param translation` is the difference between the old value and the new one.
signal value_changed(value: float, translation: float)

## Emitted when the normalized value changes.
## `param value_normal` is the new normalized value.
## `param translation` is the difference between the old normal and the new one.
signal value_normal_changed(value_normal: float, translation: float)

## Emitted when the minimum range value changes.
signal min_value_changed(value: float)

## Emitted when the maximum range value changes.
signal max_value_changed(value: float)

## Emitted when the real number value is equal to the minimum range.
signal meter_empty()

## Emitted when the real number value is equal to the maximum range.
signal meter_full()

## Emitted when the real value crosses some defined threshhold in
## `property real_value_targets`.
signal meter_met_value(threshhold: float, value: float)

## Emitted when the normal value crosses some defined threshhold in
## `property normal_value_targets`.
signal meter_met_proportion(threshhold: float, value_normal: float)


## The real value of this clamped float.
@export var value: float = 0:
   set(new_value):
      var old_value := value
      value = clampf(new_value, min_value, max_value)
      value_changed.emit(value, value - old_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true
         _set_normalized_to_real_value()
         _disable_recursive_property_editing = false

      _emit_real_value_threshholds(value, old_value)

## The normalized value of this clamped float: a range between 0 and 1.
@export var normalized_value: float = 0:
   set(new_value):
      var old_normalized_value := normalized_value
      normalized_value = clampf(new_value, 0.0, 1.0)
      value_normal_changed.emit(normalized_value, normalized_value - old_normalized_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true
         _set_real_value_to_normalized()
         _disable_recursive_property_editing = false

      _emit_normal_value_threshholds(normalized_value, old_normalized_value)


## The minimum real number value for this range.
@export_range(0, 100, 0.1, 'or_greater; hide_slider') var min_value: float = 0:
   set(new_value):
      min_value = new_value
      min_value_changed.emit(min_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true

         if min_value > max_value:
            max_value = min_value
         if min_value > value:
            value = min_value

         _disable_recursive_property_editing = false


## The maximum real number value for this range.
@export_range(0, 100, 0.1, 'or_greater; hide_slider') var max_value: float = 100:
   set(new_value):
      max_value = new_value
      max_value_changed.emit(max_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true

         if max_value < min_value:
            min_value = max_value
         if max_value < value:
            value = max_value
            
         _disable_recursive_property_editing = false

@export_subgroup('Real value emit targets')

## A list of threshhold values for which `signal meter_met_value` will be emitted when the
## real value's translation vector intersects with the threshhold.
@export var real_value_targets: PackedFloat32Array = []

@export_subgroup('Normal value emit targets')

## A list of threshhold values for which `signal meter_met_proportion` will be emitted
## when the normalized value's translation vector intersects with the threshhold.
@export var normal_value_targets: PackedFloat32Array = []


# FIXME Is there a way to do this without a side-effect?
## If true, then properties like `normalized_value` being updated should not also update
## other properties, such as `value`. Useful for updating the editor's config display
## without triggering an infinite recursion.
var _disable_recursive_property_editing := false


func _init() -> void:
   value = min_value
   max_value = max_value if max_value >= min_value else min_value

   _set_normalized_to_real_value()


## Emits signals when the real value changes to or beyond set threshhold targets.
func _emit_real_value_threshholds(new_value: float, old_value: float) -> void:
   if new_value == min_value:
      meter_empty.emit()
   if new_value == max_value:
      meter_full.emit()

   # TODO Emit once, the threshhold closest to new_value.
   for threshhold in real_value_targets:
      if sign(threshhold - new_value) != sign(threshhold - old_value):
         meter_met_value.emit(threshhold, new_value)


## Emits signals when the noramlized value changes to or beyond set threshhold targets.
func _emit_normal_value_threshholds(new_normal: float, old_normal: float) -> void:
   for threshhold in normal_value_targets:
      if sign(threshhold - new_normal) != sign(threshhold - old_normal):
         meter_met_proportion.emit(threshhold, new_normal)


## Returns the size of the numeric range.
func _get_range() -> float:
   return max_value - min_value


## Sets the normalized value to a number reflecting the current real value.
func _set_normalized_to_real_value() -> void:
   var value_range := _get_range()
   normalized_value = (
      1.0 if value_range == 0
      else (value - min_value) / value_range
   )


## Sets the real value to a number reflecting the current normalized value.
func _set_real_value_to_normalized() -> void:
   value = (normalized_value * _get_range()) + min_value


## Ensures that real and normalized values are all within the set range.
func _clamp_values() -> void:
   value = clampf(value, min_value, max_value)
   _set_normalized_to_real_value()
