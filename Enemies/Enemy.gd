extends CharacterBody3D


var speed:float = 5.0
var evade_velocity:float = 4.5

@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@export var max_target_distance: float = 2.735

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_ref:Player

func _ready() -> void:
	var detectionArea:Area3D = $DetectionArea
	detectionArea.body_entered.connect(OnDetectAreaEntered)

func UpdateTargetLocation()->void:
	var _distance:Vector3 = (player_ref.global_position - global_position)
	if _distance.length() > max_target_distance:
		print("Distance between target and " + name + " : " +str(_distance.length()))
		nav_agent.target_position = player_ref.global_position
	else :
		print("in update target location for " + name + " we can set a location close to the target if the agent is close. That way they dont just stop and idle")

func _physics_process(delta: float) -> void:
	# gravity is on by defauls
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# ###
	
	if player_ref:
		var current_location:Vector3 = global_transform.origin
		var next_location:Vector3 = nav_agent.get_next_path_position()
		
		var new_velocity = (next_location - current_location).normalized() * speed
		velocity = new_velocity
		
		var distance:float = (player_ref.global_position - global_position).length()
		# finally, move the entity if it's not close to position we are trying to get to
		if distance > max_target_distance:
			print("movin with a player ref with a velocity of " + str(velocity))
			move_and_slide()
	else:
		print("movin no player ref with a velocity of " + str(velocity))
		move_and_slide()
	
	if velocity.x != 0 and velocity.z != 0:
		rotation.y = atan2(-velocity.x, -velocity.z)
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
		player_ref = body
		UpdateTargetLocation()
		$DetectionArea.queue_free()
		var redetection_timer:Timer = Timer.new()
		redetection_timer.timeout.connect(func():
			UpdateTargetLocation()
			redetection_timer.wait_time = randf_range(0.2, 1.3)
			)
		redetection_timer.wait_time = randf_range(0.2, 1.3)
		add_child(redetection_timer)
		redetection_timer.name = "RedetectionTimer"
		redetection_timer.start()
