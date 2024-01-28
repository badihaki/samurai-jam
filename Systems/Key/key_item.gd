class_name Key
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collider:Area3D = $Area3D
	collider.body_entered.connect(OnColliderEnter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnColliderEnter(body:Node3D)->void:
	if body is Player:
		body.GetKey()
		queue_free()
