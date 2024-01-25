extends CharacterBody3D


var speed:float = 5.0
var evade_velocity:float = 4.5

@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	var detectionArea:Area3D = $DetectionArea
	detectionArea.body_entered.connect(OnDetectAreaEntered)

func UpdateTargetLocation(target_location:Vector3)->void:
	nav_agent.target_position = target_location

func _physics_process(delta: float) -> void:
	# ###
	var current_location:Vector3 = global_transform.origin
	var next_location:Vector3 = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity = new_velocity
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# move the entity
	move_and_slide()
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()

func Die()->void:
	print(owner.name + "...is dead")
	queue_free()

func OnDetectAreaEntered(body:Node3D)->void:
	if body is Player:
		print("detect player")
		UpdateTargetLocation(body.global_position)
