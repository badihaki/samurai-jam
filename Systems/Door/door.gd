class_name Door
extends Node3D

@export var required_number_of_keys:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var trigger:Area3D = $Area3D
	trigger.body_entered.connect(OnCharacterCollision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnCharacterCollision(body:Node3D)->void:
	if body is Player:
		print("door collide with player")
		if body.keys_on_chain > required_number_of_keys:
			print("open door")
			queue_free()
