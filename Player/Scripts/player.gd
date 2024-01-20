extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# camera stuff
@onready var player_cam:PhantomCamera3D = %PlayerCam

@export var mouse_sensitivity:float = 0.05

@export var min_yaw: float = -89.9
@export var max_yaw: float = 50

func _unhandled_input(event: InputEvent) -> void:
	if player_cam.get_follow_mode() == player_cam.Constants.FollowMode.THIRD_PERSON:
		SetCameraRotation(event)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	CanMove()
	CanDash()


func CanMove()->void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func SetCameraRotation(event:InputEvent)->void:
	if event is InputEventMouseMotion:
		var player_cam_rotation_degrees: Vector3
		
		# assign the current rotation of the spring arm node so it starts in the right place
		player_cam_rotation_degrees = player_cam.get_third_person_rotation_degrees()
		
		# change the x rotation
		player_cam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		# and clamp this shit
		player_cam_rotation_degrees.x = clampf(player_cam_rotation_degrees.x, min_yaw, max_yaw)
		
		# change y rotation
		player_cam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		# makes sure cam can loop around without going below 0 or above 360 degrees
		player_cam_rotation_degrees.y = wrapf(player_cam_rotation_degrees.y, 0.0, 360.0)
		
		player_cam.set_third_person_rotation(player_cam_rotation_degrees)

func CanDash()->void:
	if Input.is_action_just_pressed("dash"):
		print("dashing")
