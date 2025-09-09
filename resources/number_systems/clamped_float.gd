@tool
class_name ClampedFloat
extends Resource


## Emitted when the real number value changes.
signal value_changed(value: float)

## Emitted when the normalized value changes.
signal value_normal_changed(value_normal: float)

## Emitted when the minimum range value changes.
signal min_value_changed(value: float)

## Emitted when the maximum range value changes.
signal max_value_changed(value: float)

## Emitted when the real number value is equal to the minimum range.
signal meter_empty()

## Emitted when the real number value is equal to the maximum range.
signal meter_full()


## The real value of this clamped float.
@export var value: float = 0:
   set(new_value):
      var old_value := value
      value = clampf(new_value, min_value, max_value)
      value_changed.emit(value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true
         _set_normalized_to_real_value()
         _disable_recursive_property_editing = false

      _emit_value_targets(value, old_value)

## The normalized value of this clamped float: a range between 0 and 1.
@export var normalized_value: float = 0:
   set(new_value):
      var old_value := value

      normalized_value = clampf(new_value, 0.0, 1.0)
      value_normal_changed.emit(normalized_value)

      if not _disable_recursive_property_editing:
         _disable_recursive_property_editing = true
         _set_real_value_to_normalized()
         _disable_recursive_property_editing = false

      _emit_value_targets(value, old_value)

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


## If true, then properties like `normalized_value` being updated should not also update
## other properties, such as `value`. Useful for updating the editor's config display
## without triggering an infinite recursion.
var _disable_recursive_property_editing := false


func _init() -> void:
   value = min_value
   max_value = max_value if max_value >= min_value else min_value

   _set_normalized_to_real_value()


## Emits signals when the value reaches set targets.
func _emit_value_targets(new_value: float, old_value: float) -> void:
   if new_value == min_value:
      meter_empty.emit()
   if new_value == max_value:
      meter_full.emit()

   # IMPLEMENT Other, export-config–set target points, like 30%, etc.
   #  emission_points: Array[float] ## All normalized values
   #  if sign(emission_point - old_value) != sign(emission_point - new_value):
   #     do()


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
