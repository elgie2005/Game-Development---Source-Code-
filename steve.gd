extends CharacterBody3D  # Extends the CharacterBody3D class, allowing for movement and physics interactions.

@onready var animation_player = get_node("Steve/AnimationPlayer")  # Reference to the AnimationPlayer node for handling animations.
@onready var player_mesh = get_node("Steve")  # Reference to the player model to rotate it based on movement.
@onready var camrot_h = get_node("camroot/h")  # Reference to the camera horizontal rotation node.

@export var gravity: float = 9.8  # Gravity force applied to the player when in the air.
@export var walk_speed: int = 3  # Walking speed of the player.
@export var jump_strength: float = 5.0  # The force applied when the player jumps.

var direction: Vector3  # Stores the direction in which the player is moving.
var horizontal_velocity: Vector3  # Stores horizontal velocity (X and Z axes, no Y).
var movement_speed: int  # Current movement speed.
var angular_acceleration: int  # Speed at which the player rotates towards movement direction.
var acceleration: int  # Speed at which the player accelerates.

func _physics_process(delta: float) -> void:
	# Allows the player to exit the game by pressing ESC (ui_cancel)
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	var on_floor = is_on_floor()  # Check if the player is standing on the ground.

	# Apply gravity when the player is in the air.
	if not on_floor:
		velocity.y -= gravity * delta  # Gravity decreases the Y velocity over time.

	# Set movement and rotation variables.
	angular_acceleration = 10  # How quickly the player rotates towards movement direction.
	movement_speed = 0  # Default movement speed is 0 unless an input is detected.
	acceleration = 15  # Controls how fast the player reaches full speed.

	# Get the player's horizontal rotation to move relative to camera direction.
	var h_rot = camrot_h.global_transform.basis.get_euler().y  

	# Check if any movement input is being pressed.
	if Input.is_action_pressed("move_forward") || Input.is_action_pressed("move_backward") || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		# Calculate movement direction based on input.
		direction = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),  # Right increases X, Left decreases X
			0,  # No vertical movement handled here.
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")  # Backward increases Z, Forward decreases Z
		).rotated(Vector3.UP, h_rot).normalized()  # Rotates movement relative to camera direction.

		movement_speed = walk_speed  # Apply walking speed.

		# Play walking animation if it's not already playing.
		if animation_player.is_playing() == false:
			animation_player.play("ArmatureAction")  # Ensure this matches the correct animation name.

		# Rotate the player to face the movement direction smoothly.
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z), delta * angular_acceleration)
	else:
		# Stop the animation when the player is not moving.
		if animation_player.is_playing() == true:
			animation_player.stop()

	# Handle jumping when the player is on the floor and presses the jump key (typically Space bar, mapped to "ui_accept").
	if on_floor and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_strength  # Apply upward velocity to make the player jump.

	# Apply movement speed to velocity.
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed

	move_and_slide()  # Move the character and handle collisions smoothly.
