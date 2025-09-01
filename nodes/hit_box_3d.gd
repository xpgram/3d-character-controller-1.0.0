class_name HitBox3D
extends Area3D
## Abstract class for HitBox3D-type objects.

## Triggered when this hit box makes contact with another hit box.
signal hit_box_hit(hit_box: HitBox3D)

## The owning entity of this hit box. Used to determine whether a hit box
## collision is with 'self'.
## To avoid inconsistency errors, it is recommended to use the top-level node of
## an entity for this value, or the top-level node of the entity that spawned
## this one's scene if it is a projectile.
## By default, this value is the same as the 'owner' property.
@export var hit_box_owner: Node

## Whether this hit box can hit other hit boxes owned by the same entity.
@export var hits_self := false

## How much time, in seconds, from object instantiation until self-hitting is
## enabled. Useful for providing a safety window for projectiles when fired.
@export_custom(PROPERTY_HINT_NONE, 'suffix:s')
var hit_self_delay_timer := 0.0 # TODO Convert to real Timer object?

## The hit box layer this object **is in.** Hit boxes can exist in up to 32
## different hit box layers.
@export_flags('Player', 'Enemy') var hit_box_layer := 1

## The hit box layer this object **scans.** Hit boxes can scan up to 32
## different hit box layers.
@export_flags('Player', 'Enemy') var hit_box_mask := 1


func _init() -> void:
  area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
  if hit_self_delay_timer > 0:
    hit_self_delay_timer -= delta


## Handles collisions with other Area3D's. If the Area3D passes preliminary
## checks, then it will be passed on to _on_hit_box_entered for inheriting
## classes to handle.
func _on_area_entered(area: Area3D) -> void:
  if area is not HitBox3D:
    return

  var hit_box := area as HitBox3D

  var not_on_scanned_layer: bool = (hit_box_mask & hit_box.hit_box_layer == 0)
  if not_on_scanned_layer:
    return

  var same_owner: bool = (hit_box.hit_box_owner and hit_box.hit_box_owner == hit_box_owner)
  var cant_hit_self: bool = (not hits_self or hit_self_delay_timer > 0)
  if same_owner and cant_hit_self:
    return

  _on_hit_box_entered(hit_box)


## Virtual function to be overrided. Called when this hitbox makes contact with
## another hitbox.
func _on_hit_box_entered(_hit_box: HitBox3D) -> void:
  pass
