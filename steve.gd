extends Node3D  # The camera controller extends Node3D, allowing it to be positioned and rotated in 3D space.

# Camera rotation variables
var camroot_h: float = 0  # Stores horizontal camera rotation (yaw).
var camroot_v: float = 0  # Stores vertical camera rotation (pitch).

# Clamping values to prevent excessive vertical rotation (looking too far up or down).
@export var cam_v_max: int = 75  # Maximum vertical angle (looking up).
@export var cam_v_min: int = -55  # Minimum vertical angle (looking down).

# Mouse sensitivity for camera movement.
var h_sensitivity: float = 0.01  # Horizontal sensitivity (yaw).
var v_sensitivity: float = 0.01  # Vertical sensitivity (pitch).

# Smooth camera movement acceleration values.
var h_acceleration: float = 10.0  # How quickly the camera adjusts to horizontal input.
var v_acceleration: float = 10.0  # How quickly the camera adjusts to vertical input.

# References to camera rotation nodes.
var h_node: Node3D  # Horizontal rotation node.
var v_node: Node3D  # Vertical rotation node.

func _ready() -> void:
	# Lock the mouse cursor to the center of the screen for a smooth first-person experience.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Get references to the horizontal and vertical rotation nodes.
	h_node = get_node("h")  # Node responsible for horizontal rotation.
	v_node = get_node("h/v")  # Node responsible for vertical rotation.

	# Initialize the rotation variables with the current node rotations.
	camroot_h = h_node.rotation.y  # Set initial horizontal rotation.
	camroot_v = v_node.rotation.x  # Set initial vertical rotation.

func _input(event: InputEvent) -> void:
	# Capture mouse movement events for camera control.
	if event is InputEventMouseMotion:
		# Adjust the horizontal rotation based on mouse movement along the X-axis.
		camroot_h += -event.relative.x * h_sensitivity
		
		# Adjust the vertical rotation based on mouse movement along the Y-axis.
		camroot_v += event.relative.y * v_sensitivity

func _physics_process(delta: float) -> void:
	# Convert vertical angle limits from degrees to radians.
	var v_min_rad = deg_to_rad(cam_v_min)
	var v_max_rad = deg_to_rad(cam_v_max)

	# Clamp the vertical rotation to prevent looking too far up or down.
	camroot_v = clamp(camroot_v, v_min_rad, v_max_rad)

	# Smoothly interpolate the actual camera rotation towards the target rotation values.
	h_node.rotation.y = lerp(h_node.rotation.y, camroot_h, delta * h_acceleration)
	v_node.rotation.x = lerp(v_node.rotation.x, camroot_v, delta * v_acceleration)
