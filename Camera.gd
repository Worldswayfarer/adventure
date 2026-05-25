extends Camera3D

@export var move_speed := 8.0
@export var fast_speed := 20.0
@export var mouse_sensitivity := 0.2

var rotating := false
var yaw := 0.0   # rotation around Y (left/right)
var pitch := 0.0 # rotation around X (up/down)


func _ready():
	# Initialize yaw/pitch from current rotation
	yaw = rotation.y
	pitch = rotation.x


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed
			var mode = Input.MOUSE_MODE_VISIBLE
			if rotating:
				mode = Input.MOUSE_MODE_CAPTURED
			Input.set_mouse_mode(mode)

	if rotating and event is InputEventMouseMotion:
		yaw -= deg_to_rad(event.relative.x * mouse_sensitivity)
		pitch -= deg_to_rad(event.relative.y * mouse_sensitivity)

		# Clamp pitch so we don't flip
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))

		# Apply yaw/pitch, force roll (z) to 0
		rotation = Vector3(pitch, yaw, 0.0)

func _process(delta):
	var velocity := Vector3.ZERO
	var speed := move_speed
	if Input.is_action_pressed("camera_dash"):
		speed = fast_speed
	if Input.is_action_pressed("camera_forward"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("camera_back"):
		velocity += transform.basis.z
	if Input.is_action_pressed("camera_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("camera_right"):
		velocity += transform.basis.x

	# Optional: vertical movement like the editor
	if Input.is_action_pressed("move_up"):
		velocity += transform.basis.y
	if Input.is_action_pressed("move_down"):
		velocity -= transform.basis.y

	if velocity != Vector3.ZERO:
		global_position += velocity.normalized() * speed * delta
