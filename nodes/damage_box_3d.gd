class_name DamageBox3D
extends HitBox3D
## A HitBox3D used to deal damage to [HurtBox3D]'s.

## 
@export var damage := 1


func _on_hit_box_entered(hit_box: HitBox3D) -> void:
   pass
