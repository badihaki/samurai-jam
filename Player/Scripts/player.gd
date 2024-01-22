extends CharacterBody3D

@export_category("Charater Settings")
@export var speed = 5.0
@export var movement_is_enabled:bool = true
@export var dash_is_enabled:bool = true
@export var dash_speed = 25.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# graphics stuff
@onready var model:Node3D = $GFX

@export_category("Camera Stuff")
@onready var game_camera:Camera3D = %Camera
@onready var player_cam:PhantomCamera3D = %PlayerCam

@export var mouse_sensitivity: float = 0.05

@export var min_yaw: float = -89.9
@export var max_yaw: float = 50

@export var min_pitch: float = 0
@export var max_pitch: float = 360

func _ready() -> void:
	if player_cam.get_follow_mode() == player_cam.Constants.FollowMode.THIRD_PERSON:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if player_cam.get_follow_mode() == player_cam.Constants.FollowMode.THIRD_PERSON:
		if is_instance_valid(player_cam):
			SetCameraRotation(event)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	RotateCharacter()
	if movement_is_enabled:
		CanMove()
	if dash_is_enabled:
		CanDash()

func RotateCharacter()->void:
	if velocity.length() > 0.2:
		var look_direction: Vector2 = Vector2(velocity.z, velocity.x)
		model.rotation.y = look_direction.angle()

func CanMove()->void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var camera_dir := -game_camera.global_transform.basis.z
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var move_direction:Vector3 = Vector3.ZERO
		move_direction.x = direction.x
		move_direction.z = direction.z
		move_direction = move_direction.rotated(Vector3.UP, game_camera.rotation.y).normalized()
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

func CanDash()->void:
	if Input.is_action_just_pressed("dash"):
		movement_is_enabled = false
		dash_is_enabled = false
		var dashWait = Timer.new()
		dashWait.time_left = 0.25
		dashWait.timeout.connect()

func SetCameraRotation(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = player_cam.get_third_person_rotation_degrees()

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_yaw, max_yaw)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_pitch, max_pitch)

		# Change the SpringArm3D node's rotation and rotate around its target
		player_cam.set_third_person_rotation_degrees(pcam_rotation_degrees)
