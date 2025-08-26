class_name Jostler
extends Node3D

# TODO Use Jostler Strategies instead of different nodes.
#   Jostler is adding unsteady-cam behavior, but what if I also want that walk-cycle-thing
#   that all FPSes do? Wouldn't it be nice to have a list of resources or something that
#   all return a position/rotation that just add together before being applied?
# TODO Turn this script into a Resource.
#   This Jostler could be useful for things other than camera behavior. A washing machine, perhaps?
#   Or maybe we should just put the washing machine under a Jostler node? I'm honestly not
#   sure how else it would work.

const DEGREES_10 := PI / 18
const DEGREES_5 := PI / 36
const CUBE_DIAGONAL_LENGTH := sqrt(3)

@export_subgroup('Global Jostle', 'global_')

## Turns the Jostler on and off.
@export
var global_active := true:
   set(on):
      global_active = on
      if not on:
         _reset_transformation()

## The 'loudness' of all jostling movements. It is recommended to treat this
## normalized value as a volume knob for the entire system and describe
## specific amplitude proportions in each component.
@export_range(0, 1, 0.01, 'or_greater')
var global_amplitude := 1.0

## The rate at which the noise function is "traveled." Higher numbers yield faster jostling.
@export_custom(PROPERTY_HINT_NONE, 'suffix:∝')
var global_frequency := 20.0

## The width of the 1D noise texture used. Wider textures contain more unique noise.
## # FIXME Looping widths are not implemented: the loop implied by this number is jerky.
@export
var global_noise_width := 100_000.0

## The noise to sample. The actual noise sampled is duplicated from these settings and
## given a random seed. A default exists if one is not provided.
@export
var global_noise := FastNoiseLite.new()

@export_subgroup('Rotation Jostle', 'rotation_')

## Turns the rotational jostling on and off.
@export
var rotation_active := true:
   set(on):
      rotation_active = on
      if not on:
         _reset_rotation()

# FIXME It bothers me that these are not real degrees. Do some testing.
## The maximum range for rotations on each axis in degrees.
@export_custom(PROPERTY_HINT_LINK, 'radians, suffix:°')
var rotation_amplitude := Vector3(DEGREES_10, DEGREES_10, DEGREES_5)

## The rates for each axis at which noise is "traveled." Higher numbers yield faster jostling.
@export_custom(PROPERTY_HINT_LINK, 'suffix:∝')
var rotation_frequency := Vector3(1.0, 1.0, 1.0)

## The shift of the noise function on each axis as they relate to other jostle components
## using the same noise.
@export_custom(PROPERTY_HINT_LINK, 'suffix:s')
var rotation_delay := Vector3(0.25, 0.25, 0.25)

## The response curve for rotation noise values. A range over [0,1] describes an output
## curve for both the positive and negative directions extending from point 0. Useful for
## subduing overall motion while retaining the occasional spike.
@export
var rotation_steadiness_curve: Curve

@export_subgroup('Position Jostle', 'position_')

## Turns the positional jostling on and off.
@export
var position_active := true:
   set(on):
      position_active = on
      if not on:
         _reset_position()

## The maximum range for movement on each axis in meters.
@export_custom(PROPERTY_HINT_LINK, 'suffix:m')
var position_amplitude := Vector3(1.0, 1.0, 1.0)

## The rates for each axis at which noise is "traveled." Higher numbers yield faster jostling.
@export_custom(PROPERTY_HINT_LINK, 'suffix:∝')
var position_frequency := Vector3(1.0, 1.0, 1.0)

## The shift of the noise function on each axis as they relate to other jostle components
## using the same noise.
@export_custom(PROPERTY_HINT_LINK, 'suffix:s')
var position_delay := Vector3(0.0, 0.0, 0.0)

## The response curve for position noise values. A range over [0,1] describes an output
## curve for both the positive and negative directions extending from point 0. Useful for
## subduing overall motion while retaining the occasional spike.
@export
var position_steadiness_curve: Curve

var x_noise: FastNoiseLite
var y_noise: FastNoiseLite
var z_noise: FastNoiseLite

## The current coordinate position to sample from each noise function.
var noise_cursor := 0.0

# TODO Add a tween on/off that adjusts global amplitude
# func tween_amplitude(time_seconds: float, value: float)
# func start(time_seconds: float, value: float = 1.0)
# func stop(time_seconds: float, value: float = 0.0)


func _ready() -> void:
   if not global_noise:
      global_noise = FastNoiseLite.new()
      # TODO This should go above if we're not customizing anything.
      #   And speaking of customization, its default should really be a saved resource, anyway.

   x_noise = global_noise.duplicate(true)
   y_noise = global_noise.duplicate(true)
   z_noise = global_noise.duplicate(true)

   x_noise.seed = randi()
   y_noise.seed = randi()
   z_noise.seed = randi()

   # TODO I should preload() a saved LinearCurve resource instead of doing this.
   if not rotation_steadiness_curve:
      rotation_steadiness_curve = Curve.new()
      rotation_steadiness_curve.add_point(Vector2(0, 0), 1, 1)
      rotation_steadiness_curve.add_point(Vector2(1, 1), 1, 1)
   if not position_steadiness_curve:
      position_steadiness_curve = Curve.new()
      position_steadiness_curve.add_point(Vector2(0, 0), 1, 1)
      position_steadiness_curve.add_point(Vector2(1, 1), 1, 1)


func _physics_process(delta: float) -> void:
   if not global_active:
      return

   noise_cursor += delta
   _jostle_rotation()
   _jostle_position()


## Reset all jostle components to their default states.
func _reset_transformation() -> void:
   _reset_rotation()
   _reset_position()


## Reset rotational jostle to its default state.
func _reset_rotation() -> void:
   rotation = Vector3.ZERO


## Reset positional jostle to its default state.
func _reset_position() -> void:
   position = Vector3.ZERO


## Physics process step for the rotation component.
func _jostle_rotation() -> void:
   if not rotation_active:
      return

   var new_rotation_vector := _get_vector_at_noise_coordinate(
      noise_cursor,
      rotation_amplitude,
      rotation_frequency,
      rotation_delay,
      rotation_steadiness_curve,
   )

   # Rotational movement "along the x-axis" is actually controlled by the y-axis,
   # so we must map them to reflect similar motions in position.
   rotation.x = new_rotation_vector.y
   rotation.y = -new_rotation_vector.x
   rotation.z = new_rotation_vector.z


## Physics process step for the position component.
func _jostle_position() -> void:
   if not position_active:
      return

   var new_position_vector := _get_vector_at_noise_coordinate(
      noise_cursor,
      position_amplitude,
      position_frequency,
      position_delay,
      position_steadiness_curve,
   )

   position = new_position_vector


## Returns a [Vector3] of noise values.
## `param x_coordinate` is where along the noise function the values should be sampled.
## `param amplitude_vector` controls the size of the values for each axis.
## `param frequency_vector` controls relative density of the noise function's undulations.
## `param delay_vector` controls the shift of each axis sample relative to other components.
## `param steadiness_curve` maps the axis sample output to a bezier curve.
func _get_vector_at_noise_coordinate(
   x_coordinate: float,
   amplitude_vector: Vector3,
   frequency_vector: Vector3,
   delay_vector: Vector3,
   steadiness_curve: Curve,
) -> Vector3:
   var coord_vector := Vector3(
      # FIXME As predicted, this noise_width setting is jerky as hell.
      fmod((x_coordinate - delay_vector.x), global_noise_width),
      fmod((x_coordinate - delay_vector.y), global_noise_width),
      fmod((x_coordinate - delay_vector.z), global_noise_width),
   )

   var noise_vector := Vector3(
      # Note: get_noise_1d() returns noise_vector over a [-1, 1] range.
      x_noise.get_noise_1d(coord_vector.x * frequency_vector.x * global_frequency),
      y_noise.get_noise_1d(coord_vector.y * frequency_vector.y * global_frequency),
      z_noise.get_noise_1d(coord_vector.z * frequency_vector.z * global_frequency),
   )

   # Apply steadiness curve.
   var normalized_length = noise_vector.length() / CUBE_DIAGONAL_LENGTH
   var curved_length = steadiness_curve.sample(normalized_length)
   noise_vector = noise_vector.normalized() * curved_length

   noise_vector = noise_vector * amplitude_vector * global_amplitude

   return noise_vector
