# class_name CameraRig3D_2
extends Node3D

# TODO Actually, I think this isn't necessary here. This would go in a controller script somewhere.
const InputUtils = preload('uid://tl2nnbstems3')

# TODO Preload and instantiate the .tscn for the rig's contents?
#  So a rig can be added simply via the node dialog.


## (NULLABLE) The primary subject of focus that the camera's transform should be oriented
## around. This object is not necessarily where the camera will be looking; that is
## ultimately up to the provided camera rig controller.
@export var subject: Node3D

# TODO Better name?
## Various settings and configurations for this CameraRig3D, such as its ideal transform
## and movement speeds.
@export var camera_settings: CameraRigSettings3D


# TODO Make this a little more generic via a common CameraRigController interface.
#  Not all will be stacks that listen for CameraRegion collisions.
## (NULLABLE) An object which yields a [CameraRigController3D] when asked.
var _camera_controller_service: CameraRigControllerStack3D

## The pivot joint used to rotate the camera arm.
@onready var _pivot: Node3D = %Pivot

## The arm that holds the camera head at a distance from the rig's base coordinates.
@onready var _camera_arm: Node3D = %CameraArm

## A pivot joint used to rotate the camera's lense and related accessories.
@onready var _camera_head: Node3D = %CameraHead

## The point describing where the camera is looking.
@onready var _focal_point: Node3D = %FocalPoint

## The jostle component that handles subtle movements, like camera sway or jitter.
@onready var jostler: Jostler = %Jostler

## The camera object that renders the scene.
@onready var camera_lense: Camera3D = %Camera3D

## A light attached to the camera, pointed in the same direction.
@onready var camera_spotlight: SpotLight3D = %Spotlight3D



func _ready() -> void:
   teleport_to_position()


func _physics_process(delta: float) -> void:
   var camera_controller := _camera_controller_service.get_controller()
   # camera_controller.operate_rig(delta, self)

   # TODO Run common behavior strategies, if enabled (e.g., player tilt camera)
   #  I need to think about how I want to do this a bit, first.

   _move_toward_position(delta, camera_settings.skip_animation)


## Animates the rig's actual transforms to their set values.
## If `param skip_animation` is true, then the rig will instantly assume its set transform.
func _move_toward_position(delta: float, skip_animation := false) -> void:
   # Assign lerp weights for each transform.
   var lerp_weight_rig_position := (
      Vector3.ONE if skip_animation
      else camera_settings.lerp_rate_rig_position * delta
   )
   var lerp_weight_rig_rotation := (
      Vector3.ONE if skip_animation
      else camera_settings.lerp_rate_rig_rotation * delta
   )
   var lerp_weight_pivot_rotation := (
      Vector3.ONE if skip_animation
      else camera_settings.lerp_rate_pivot_rotation * delta
   )
   var lerp_weight_arm_length := (
      1.0 if skip_animation
      else camera_settings.lerp_rate_arm_length * delta
   )
   var lerp_weight_focal_point := (
      Vector3.ONE if skip_animation
      else camera_settings.lerp_rate_focal_point * delta
   )

   # Assign displacements to set transforms.
   var rig_position := camera_settings.rig_position + camera_settings.rig_position_displacement
   var global_focal_point := camera_settings.focal_point + camera_settings.focal_point_displacement

   # Animate the actual transforms to the set transforms.
   # TODO Is this level of granularity too much? Especially considering it probably suffers the 1.4 diagonal problem.
   position.x = lerp(position.x, rig_position.x, lerp_weight_rig_position.x)
   position.y = lerp(position.y, rig_position.y, lerp_weight_rig_position.y)
   position.z = lerp(position.z, rig_position.z, lerp_weight_rig_position.z)

   rotation.x = lerp_angle(rotation.x, camera_settings.rig_rotation.x, lerp_weight_rig_rotation.x)
   rotation.y = lerp_angle(rotation.y, camera_settings.rig_rotation.y, lerp_weight_rig_rotation.y)
   rotation.z = lerp_angle(rotation.z, camera_settings.rig_rotation.z, lerp_weight_rig_rotation.z)

   _pivot.rotation.x = lerp_angle(_pivot.rotation.x, camera_settings.pivot_rotation.x, lerp_weight_pivot_rotation.x)
   _pivot.rotation.y = lerp_angle(_pivot.rotation.y, camera_settings.pivot_rotation.y, lerp_weight_pivot_rotation.y)
   _pivot.rotation.z = lerp_angle(_pivot.rotation.z, camera_settings.pivot_rotation.z, lerp_weight_pivot_rotation.z)

   _camera_arm.position.z = lerp(_camera_arm.position.z, camera_settings.arm_length, lerp_weight_arm_length)

   _focal_point.global_position.x = lerp(_focal_point.global_position.x, global_focal_point.x, lerp_weight_focal_point.x)
   _focal_point.global_position.y = lerp(_focal_point.global_position.y, global_focal_point.y, lerp_weight_focal_point.y)
   _focal_point.global_position.z = lerp(_focal_point.global_position.z, global_focal_point.z, lerp_weight_focal_point.z)

   _camera_head.look_at(_focal_point.global_position, Vector3.UP)


## Moves the rig's actual transforms to their set values instantly, skipping all lerp
## animations.
func teleport_to_position() -> void:
   # FIXME Why are we providing a delta that doesn't exist?
   _move_toward_position(0.0, true)
