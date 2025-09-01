@tool
class_name CameraTarget3D
extends Area3D
## A type of [Area3D] for interacting with [CameraRegion3D]'s.


func _init() -> void:
   monitorable = false
   area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
   if area is not CameraRegion3D:
      return
   var camera_region := area as CameraRegion3D

   # TODO How necessary is this if the Player3D is the one managing this?
   #  This script could emit its own signal that Player3D listens for, which
   #  then passes the controller on to its player camera.
   Events.camera_region_entered.emit(self, camera_region.controller)
