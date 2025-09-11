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

## A list of camera rig camera_behaviors to apply during the physics process step.
@export var camera_behaviors: Array[CameraRigBehavior3D] = []


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
   if _camera_controller_service:
      var camera_controller := _camera_controller_service.get_controller()
      # camera_controller.operate_rig(delta, self)

   for behavior in camera_behaviors:
      behavior.process(delta)

   _move_camera_rig(delta)


## Using the sum of this rig's transform settings and the provided transforms of each
## assigned camera behavior, sets this rig's actual transform values.
func _move_camera_rig(delta: float) -> void:
   camera_settings.lerp_transform(delta)
   var new_transform := camera_settings.get_actual_transform()

   # Sum all assigned camera behaviors into one transform.
   for behavior in camera_behaviors:
      new_transform += behavior.get_rig_transform()

   # Apply new transform values to the rig's various transforms.
   position = new_transform.rig_position
   rotation = new_transform.rig_rotation
   _pivot.rotation = new_transform.pivot_rotation
   _camera_arm.position.z = new_transform.arm_length
   _focal_point.global_position = new_transform.focal_point

   # Point the camera head at the focal point.
   _camera_head.look_at(_focal_point.global_position, Vector3.UP)


## Moves the rig's actual transforms to their set values instantly, skipping all lerp
## animations.
func teleport_to_position() -> void:
   camera_settings.skip_animation()
