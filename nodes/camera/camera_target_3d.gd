@tool
class_name CameraTarget3D
extends Area3D
## A type of [Area3D] for interacting with [CameraRegion3D]'s.


func _init() -> void:
   monitorable = false
   area_entered.connect(_on_area_entered)
   area_exited.connect(_on_area_exited)


## Handler for area_entered events.
func _on_area_entered(area: Area3D) -> void:
   if area is not CameraRegion3D:
      return
   var camera_region := area as CameraRegion3D

   Events.camera_region_entered.emit(self, camera_region)


## Handler for area_exited events.
func _on_area_exited(area: Area3D) -> void:
   if area is not CameraRegion3D:
      return
   var camera_region := area as CameraRegion3D

   Events.camera_region_exited.emit(self, camera_region)
