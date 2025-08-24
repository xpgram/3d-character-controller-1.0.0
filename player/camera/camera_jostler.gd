extends Node3D

# TODO Use Jostler filters instead of different nodes.
#   Jostler is adding unsteady-cam behavior, but what if I also want that walk-cycle-thing
#   that all FPSes do? Wouldn't it be nice to have a list of resources or something that
#   all return a position/rotation that just add together before being applied?

@export var noise: FastNoiseLite
@export var rotation_delay := 1.0   # How long after position rotations of the same kind are seen
@export var amplitude := 1.0        # How large the movements are
# TODO subgroup amplitude_x_ratio, y_ratio, z_ratio to control axis motion at varying levels.
@export var rumble := 4.0           # Speed while "traveling" the noise
@export_range(1.0, 4.0, 0.1)
var steadiness := 1.0               # How much small-motion dampening there is

var x_noise: FastNoiseLite
var y_noise: FastNoiseLite
var z_noise: FastNoiseLite

var noise_cursor := 0.0

var jostle_position := Vector3()
var jostle_rotation := Vector3()


func _ready() -> void:
   x_noise = noise.duplicate(true)
   y_noise = noise.duplicate(true)
   z_noise = noise.duplicate(true)

   x_noise.seed = randi()
   y_noise.seed = randi()
   z_noise.seed = randi()


func _physics_process(delta: float) -> void:
   noise_cursor += delta

   # _jostle_position()
   _jostle_rotation()


func _jostle_position() -> void:
   var values := _get_vector_at_coordinate(noise_cursor)
   position = values


func _jostle_rotation() -> void:
   # TODO What if there are different delays for different axes?
   var values := _get_vector_at_coordinate(noise_cursor - rotation_delay)
   rotation = values


func _get_vector_at_coordinate(x: float) -> Vector3:
   x = fmod(x, 100.0)

   var values := Vector3(
      x_noise.get_noise_1d(x * rumble), # TODO Adjust x by individual rumbles
      y_noise.get_noise_1d(x * rumble),
      0.0, # z_noise.get_noise_1d(x * rumble),
   )

   values = values * amplitude

   # FIXME Steadiness does not work. Causes errors.
   values.x **= steadiness
   values.y **= steadiness
   values.z **= steadiness

   return values
