@tool

class_name Hurtbox

extends Area3D

signal hitbox_collided
@export var health_component:Health

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", _OnHitboxEntered)
	connect("hitbox_collided", health_component.ChangeHealth)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _OnHitboxEntered(hitbox:Hitbox)->void:
	if hitbox == null:
		return
	
	if hitbox.owner != owner:
		hitbox_collided.emit(hitbox.damage)
		print("hit a hittable")
