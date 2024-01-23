@tool

class_name Hurtbox

extends Area3D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", _OnHitboxEntered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _OnHitboxEntered()->void:
	pass
