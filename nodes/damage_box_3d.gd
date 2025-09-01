class_name DamageBox3D
extends HitBox3D
## A HitBox3D used to deal damage to [HurtBox3D]'s.


## Triggered when this hurt box makes contact with a [DamageBox3D].
signal hurt_box_hit(hurt_box: HurtBox3D)

## How much damage this damage box inflicts to a [HurtBox3D].
@export var damage := 1


func _on_hit_box_entered(hit_box: HitBox3D) -> void:
   if hit_box is HurtBox3D:
      hurt_box_hit.emit(hit_box as HurtBox3D)
