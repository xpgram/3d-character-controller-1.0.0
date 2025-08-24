extends Node3D

# TODO Use Jostler filters instead of different nodes.
#   Jostler is adding unsteady-cam behavior, but what if I also want that walk-cycle-thing
#   that all FPSes do? Wouldn't it be nice to have a list of resources or something that
#   all return a position/rotation that just add together before being applied?
# TODO This Jostler could be useful for things other than camera behavior. A washing machine, perhaps?

@export_subgroup('Global Jostle', 'global_')
@export var global_active := true
@export var global_amplitude := 1.0    ## The volume of the jostle.
@export var global_frequency := 1.0    ## The speed of the jostle.
@export var global_noise_width := 10.0 ## The width of the 1D noise textures used. # TODO This isn't really implemented.
@export var global_noise := FastNoiseLite.new()

@export_subgroup('Rotation Jostle', 'rotation_')
@export
var rotation_active := true
@export_custom(PROPERTY_HINT_LINK, '')
var rotation_amplitude := Vector3(1.0, 1.0, 0.0)   ## How large the jostle movements are in degrees.
@export_custom(PROPERTY_HINT_LINK, '')
var rotation_frequency := Vector3(4.0, 4.0, 4.0)   ## The amount of 'rumble'. Lower values yield slower movement.
@export_custom(PROPERTY_HINT_LINK, '')
var rotation_delay := Vector3(1.0, 1.0, 1.0)       ## 
@export
var rotation_steadiness_curve: Curve               ## The response curve for the normalized values.

@export_subgroup('Position Jostle', 'position_')
@export
var position_active := true
@export_custom(PROPERTY_HINT_LINK, '')
var position_amplitude := Vector3(1.0, 1.0, 1.0)   ## How large the jostle movements are in degrees.
@export_custom(PROPERTY_HINT_LINK, '')
var position_frequency := Vector3(4.0, 4.0, 4.0)   ## The amount of 'rumble'. Lower values yield slower movement.
@export_custom(PROPERTY_HINT_LINK, '')
var position_delay := Vector3(0.0, 0.0, 0.0)       ## 
@export
var position_steadiness_curve: Curve               ## The response curve for the normalized values.

var x_noise: FastNoiseLite
var y_noise: FastNoiseLite
var z_noise: FastNoiseLite

var noise_cursor := 0.0

var jostle_position := Vector3()
var jostle_rotation := Vector3()


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
   noise_cursor += delta

   _jostle_rotation()
   _jostle_position()


func _jostle_rotation() -> void:
   if not rotation_active:
      return

   var new_rotation_vector := _get_vector_at_coordinate(
      noise_cursor,
      rotation_amplitude,
      rotation_frequency,
      rotation_delay,
      rotation_steadiness_curve,
   )
   rotation = new_rotation_vector


func _jostle_position() -> void:
   if not position_active:
      return

   var new_position_vector := _get_vector_at_coordinate(
      noise_cursor,
      position_amplitude,
      position_frequency,
      position_delay,
      position_steadiness_curve,
   )
   position = new_position_vector


func _get_vector_at_coordinate(
   x_coordinate: float,
   amplitude_vector: Vector3,
   frequency_vector: Vector3,
   delay_vector: Vector3,
   steadiness_curve: Curve,
) -> Vector3:
   var coord_vector := Vector3(
      fmod((x_coordinate - delay_vector.x), global_noise_width),
      fmod((x_coordinate - delay_vector.y), global_noise_width),
      fmod((x_coordinate - delay_vector.z), global_noise_width),
   )

   var values := Vector3(
      x_noise.get_noise_1d(coord_vector.x * frequency_vector.x),
      y_noise.get_noise_1d(coord_vector.y * frequency_vector.y),
      z_noise.get_noise_1d(coord_vector.z * frequency_vector.z),
   )

   values = values * amplitude_vector

   values.x = steadiness_curve.sample(values.x)
   values.y = steadiness_curve.sample(values.y)
   values.z = steadiness_curve.sample(values.z)

   return values
