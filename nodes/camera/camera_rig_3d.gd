class_name CameraRig3D
extends Node3D

# TODO Turn this into a node type summonable from the node dialog.
#   That is, save the internals of CameraRig3D as a tscn, and simply instantiate
#   it here. But question: can I still take advantage of Unique Names and such
#   using this method?

# TODO This content-slot setup may actually be harder to use.
#   What if I want the control script to control the spotlight? I have to guarantee it
#   exists somehow. So, maybe I should treat the CameraRig3D like a more complicated
#   Camera3D object.

const InputUtils = preload('uid://tl2nnbstems3')

@export_group('Camera')
@export var subject: Node3D
@export var control_script: Node3D # TODO This needs a unique type.
                                   # TODO control_script can use bezier curves or whatever it wants.
@export_subgroup('Camera Settings')
# TODO Assess: When control scripts are added, is this field still useful?
## The displacement from the subject's coordinates of the camera rig's position.
@export var camera_position_displacement := Vector3(0, 5.0, 0)
## The displacement from the subject's coordinates of the camera's focal point (where it
## is looking).
@export var camera_focal_point_displacement := Vector3(0, 2.0, 0)
# TODO I should turn all these lerp rates into a type that auto-manages the values.
## How quickly the camera's position races to match the x-axis position of its subject.
@export var position_lerp_rate_x: float = 24.0
## How quickly the camera's position races to match the y-axis position of its subject.
@export var position_lerp_rate_y: float = 6.0
## How quickly the camera's focal point races to match the position of its subject.
@export var focal_point_lerp_rate: float = 24.0
## How quickly the camera's pivot rotation races to match its ideal orientation.
@export var pivot_lerp_rate: float = 4.0
## How far the camera arm extends from the rig's coordinates.
@export var camera_distance: float = 16.0
## How far in degrees the camera arm will rotate horizontally when tilt-looking.
@export var tilt_hor_max_degrees: float = 15.0
## How far in degrees the camera arm will rotate vertically when tilt-looking.
@export var tilt_ver_max_degrees: float = 15.0
## How far the camera zooms in when the player is tilt-looking.
@export var camera_tilt_zoom_distance: float = 4.0

# TODO I should pop these settings into a singleton node.
@export_group('Control Settings')
@export_subgroup('Mouse and Keyboard')
@export var mouse_sensitivity: float = 0.15
@export var mouse_invert_y: bool = false
@export var mouse_invert_x: bool = false
@export_subgroup('Controller')
@export var stick_sensitivity: float = 0.25
@export var stick_invert_y: bool = false
@export var stick_invert_x: bool = false

## The point describing where the camera is looking.
@onready var _focal_point: Node3D = %FocalPoint
## The pivot joint used to rotate the camera arm.
@onready var _pivot: Node3D = %Pivot
## The arm that holds the camera head at a distance from the rig's base coordinates.
@onready var _camera_arm: Node3D = %CameraArm
## A pivot joint used to rotate the camera's lense and related accessories.
@onready var _camera_head: Node3D = %CameraHead


func _ready() -> void:
   _move_children_to_camera_head_mount()
   _teleport_to_position()


## Reparents [Camera3D] and camera accessories from the [CameraRig3D] root node
## to the CameraHead content slot.
func _move_children_to_camera_head_mount() -> void:
   # TODO Godot does not currently support content slots like you might see in React or
   # Svelte, but there is an open pull request to expose certain hidden child nodes, so it
   # may be in the future.

   var children := get_children()

   # Exclude children packed into the .tscn.
   children = children.filter(func (child):
      if child in [_focal_point, _pivot]:
         return false
      return true
   )

   for child in children:
      child.get_parent().remove_child(child)
      _camera_head.add_child(child)


## Skips all the animation lerps used in physics processes elsewhere.
func _teleport_to_position() -> void:
   # IMPLEMENT Run the same functions with lerp(x, new_x, 1.0)?

   if subject:
      _focal_point.global_position = subject.global_position


func _physics_process(delta: float) -> void:
   if not subject:
      return

   _process_camera_rig_position(delta)
   _process_camera_arm_rotation(delta)
   _point_camera_head_at_subject(delta)


# TODO This will be controlled by camera controller scripts, actually.
#   But I should keep this as default behavior, maybe.
## Positions the camera rig over its subject's coordinates.
func _process_camera_rig_position(delta: float) -> void:
   var ideal_position := subject.position + camera_position_displacement
   ideal_position.z = 0.0

   position.x = lerp(position.x, ideal_position.x, position_lerp_rate_x * delta)
   position.y = lerp(position.y, ideal_position.y, position_lerp_rate_y * delta)


# TODO This may be (is definitely) mixing too much user control script in with generic CameraRig3D functions. We should refactor.
## Rotates the camera arm and adjusts arm length according to user input.
func _process_camera_arm_rotation(delta: float) -> void:
   var stick_input := InputUtils.get_camera_look_vector()

   # Rotate the arm.
   var ideal_pivot_rotation := Vector3(
      -stick_input.y * PI * tilt_ver_max_degrees / 180.0,
      -stick_input.x * PI * tilt_hor_max_degrees / 180.0,
      0,
   )

   _pivot.rotation.y = lerp_angle(_pivot.rotation.y, ideal_pivot_rotation.y, pivot_lerp_rate * delta)
   _pivot.rotation.x = lerp_angle(_pivot.rotation.x, ideal_pivot_rotation.x, pivot_lerp_rate * delta)

   # Retract the arm while tilt-looking.
   var arm_retraction_length := stick_input.length() * camera_tilt_zoom_distance
   _camera_arm.position.z = lerp(_camera_arm.position.z, camera_distance - arm_retraction_length, pivot_lerp_rate * delta)

   # Add extra tilt by moving the camera's focal point.
   # TODO These values lack export settings. Also should probably be in a separate control script: CameraRig is not responsible for this.
   camera_focal_point_displacement.x = lerp(camera_focal_point_displacement.x, -stick_input.x * 4.0, pivot_lerp_rate * delta)
   camera_focal_point_displacement.y = lerp(camera_focal_point_displacement.y, -stick_input.y * 2.0 + 2.0, pivot_lerp_rate * delta)

   camera_focal_point_displacement.z = lerp(camera_focal_point_displacement.z, stick_input.length() * (-subject.position.z - (subject.velocity.z * 12.0 * delta)), pivot_lerp_rate * delta)
   # TODO This line is silly. Effective, but architecturally broken.
   # This equation:
   #   [ curved_stick_input.length() * (-subject.position.z - (subject.velocity.z * 12.0 * delta)) ]
   # is doing a number of different things, all of them awful.
   # - The CameraRig does not assume its subject is a CharacterBody, so should not assume it has a velocity field.
   # - It should not know what that CharacterBody's speed value is. (12.0)
   # - It should not be trying to translate a local-space vector (the displacement) to some other local-space. This is
   #   unwrapping a wrapped present.
   # This present unwrapping is imperfectly mixing localities (that is, the subject's and global), which is what causes
   # that elastic effect when moving along the z-axis with tilt-look engaged. That elasticity is what this equation is
   # correcting for, and it would be far better to just reduce how much of the subject's z-axis locality is included in
   # the first place.
   #
   # As it is, this is fine for demonstration purposes, I guess.
   #
   # Also, this z-axis specificity will not play nicely with the corner-wrapping I want to do later.


## If a subject exists, rotates the camera head such that its visual center is facing the
## sum of the subject's coordinates and the camera_focal_point_displacement vector.
func _point_camera_head_at_subject(delta: float) -> void:
   if not subject:
      return

   # TODO Decouple focal_point from subject.position: It may actually be unhelpful to describe this rigid target-snapping
   # here in this CameraRig function. I'd have more control if this function _only_ cared about the focal_point, and the
   # focal_point was snapped to subject elsewhere, like in a controller script.
   var ideal_focal_point := subject.global_position + camera_focal_point_displacement
   _focal_point.global_position = _focal_point.global_position.move_toward(ideal_focal_point, focal_point_lerp_rate * delta)
   _camera_head.look_at(_focal_point.global_position, Vector3.UP)
