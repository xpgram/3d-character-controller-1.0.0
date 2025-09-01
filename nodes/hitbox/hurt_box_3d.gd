class_name HurtBox3D
extends HitBox3D
## A HitBox3D used to receive damage from [DamageBox3D]'s.


## Triggered when this hurt box makes contact with a [DamageBox3D].
signal hit_taken(damage_box: DamageBox3D)


func _on_hit_box_entered(hit_box: HitBox3D) -> void:
  if hit_box is DamageBox3D:
    hit_taken.emit(hit_box as DamageBox3D)
