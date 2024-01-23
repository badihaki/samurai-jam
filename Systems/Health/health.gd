@tool
class_name Health

extends Node

signal health_changed
signal entity_died

@export var max_health:int = 10
@export var current_health:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	if owner.has_method("Die"):
		connect("entity_died", owner.Die)
	else:
		printerr(owner.name+" has no function called 'Die'. Need to add this funct!!")

func ChangeHealth(value:int)->void:
	print("changing health for "+owner.name)
	print("changing health by amount: " + str(value))
	current_health -= value
	health_changed.emit(current_health)
	if current_health > max_health:
		current_health = max_health
	elif current_health <= 0:
		entity_died.emit()
