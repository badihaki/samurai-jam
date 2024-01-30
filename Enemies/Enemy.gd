extends CharacterBody3D


@export var speed:float = 5.0
@export var evade_velocity:float = 4.5

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
		if !player_ref:
			print("no target")
		else:
			print("Caught up to target")
		#print("in update target location for " + name + " we can set a location close to the target if the agent is close. That way they dont just stop and idle")

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
			#print("movin with a player ref with a velocity of " + str(velocity))
			rotation.y = atan2(-velocity.x, -velocity.z)
			move_and_slide()
	else:
		#print("movin no player ref with a velocity of " + str(velocity))
		move_and_slide()

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
