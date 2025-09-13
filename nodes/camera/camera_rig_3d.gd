class_name CameraRig3D
extends Node3D

# TODO Preload and instantiate the .tscn for the rig's contents?
#  So a rig can be added simply via the node dialog.


## (NULLABLE) The primary subject of focus that the camera's transform should be oriented
## around. This object is not necessarily where the camera will be looking; that is
## ultimately up to the provided camera rig controller.
@export var subject: Node3D

## A list of camera rig camera_behaviors to apply during the physics process step.
@export var camera_behaviors: Array[ICameraRigBehavior3D] = []

## The rotation of the pivot arm. Useful for managing a player's rotational input even
## while the rig itself is rotated.
@export_custom(PROPERTY_HINT_NONE, 'radians, suffix:°')
var pivot_rotation := Vector3.ZERO

## The distance from the rig's position to where the camera head is located.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var arm_length: float = 0

## A point in global space describing where the camera head is looking. Also used to
## inform the depth of field system.
@export_custom(PROPERTY_HINT_NONE, 'suffix:m')
var focal_point := Vector3.ZERO

# TODO Make this a parent node instead of a component I have to verify.
## (NULLABLE) An object which yields a [CameraRigController3D] when asked.
var _camera_controller_service: CameraRigControllerStack3D

# FIXME These @onready references force an initialization order among the Rig's siblings.
#  If the subject is a Player3D, and it needs to know what direction the camera is facing
#  to handle player input properly, in its own _ready step specifically, then it must
#  _ready() after this Rig has finished readying. I cannot just assume `@onready %Children`
#  are accessible any time.
#  This is a really bothersome architectural issue, actually.
#
#  For now, this Rig is being ready'd before Player3D and its state_machine, so its
#  temporarily manageable.

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
   # TODO If controller is a parent node, this shouldn't be necessary.
   for child in get_children():
      if child is CameraRigControllerStack3D:
         _camera_controller_service = child
         break

   _update_transforms()


func _physics_process(delta: float) -> void:
   # FIXME Have something else handle this process.
   #  I've stuck this in here as a temporary measure.
   _reset_transforms()

   if _camera_controller_service:
      var camera_controller := _camera_controller_service.get_controller()
      camera_controller.operate_rig(delta, self)

   for behavior in camera_behaviors:
      if behavior.enabled:
         behavior.update_camera_rig(delta, self)

   _update_transforms()


# FIXME Have something else handle this process.
func _reset_transforms() -> void:
   position = Vector3.ZERO
   rotation = Vector3.ZERO
   pivot_rotation = Vector3.ZERO
   arm_length = 16.0
   focal_point = Vector3.ZERO


## Maps the rig's public API values to its component transforms.
func _update_transforms() -> void:
   _pivot.rotation = pivot_rotation
   _camera_arm.position.z = arm_length
   _focal_point.global_position = focal_point

   # Point the camera head at the focal point.
   _camera_head.look_at(_focal_point.global_position, Vector3.UP)
