class_name CameraController
extends Node


var camera: Camera3D
var subject: Node3D


@warning_ignore('shadowed_variable')
func init(camera: Camera3D, subject: Node3D) -> void:
   self.camera = camera
   self.subject = subject


func _process(delta: float) -> void:
   pass
   # TODO Implement default camera follow behavior.
   # TODO Also, factor out a bunch of common camera behaviors, like pointing at the subject.
   # TODO Also, factor out the lerp-to-ideal behavior with customizable speed and such.
