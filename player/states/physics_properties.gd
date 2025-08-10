class_name PhysicsProperties
extends Node

@export_group("Movement Properties", "prop_move_")
@export var prop_move_speed: float = 10.0
@export var prop_move_acceleration: float= 50.0
# TODO Rename to dime_stopping_speed. Add a different slowdown speed? Friction?
@export var prop_move_stopping_speed: float = 2.0
@export var prop_move_rotation_speed: float = 20.0
@export var prop_move_jump_impulse: float = 16.0
@export var prop_move_min_jump_impulse: float = 8.0

@export_group("Physics Properties", "prop_physics_")
@export var prop_physics_gravity: float = 40.0
@export var prop_physics_terminal_velocity: float = 40.0
