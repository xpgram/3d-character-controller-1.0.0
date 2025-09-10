# class_name CameraRig3D_2
extends Node3D

# TODO Actually, I think this isn't necessary here. This would go in a controller script somewhere.
const InputUtils = preload('uid://tl2nnbstems3')

# TODO Preload and instantiate the .tscn for the rig's contents?
#  So a rig can be added simply via the node dialog.


## The primary subject of focus that the camera's transform should be oriented around.
## This object is not necessarily where the camera will be looking; that is ultimately up
## to the provided camera rig controller.
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
