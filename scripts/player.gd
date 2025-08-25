extends CharacterBody3D

@onready var camera_mount: Node3D = $camera_mount

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

@export_range(0, 1000) var min_zoom := 2
@export_range(0, 1000) var max_zoom := 25
@export_range(0, 1000, 0.1) var zoom_speed := 50.0
@export_range(0, 1, 0.1) var zoom_speed_damp := 0.5

var sens_horizontal = 0.5

var _zoom_direction = 0

@onready var camera = $camera_mount/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_rotate_left"):
		rotate_y(deg_to_rad(45))
	elif event.is_action_pressed("camera_rotate_right"):
		rotate_y(deg_to_rad(-45))
	if event.is_action_pressed("zoom_in"):
		_zoom_direction = -1
	elif event.is_action_pressed("zoom_out"):
		_zoom_direction = 1

func _process(delta: float) -> void:
	_zoom(delta)
	
func _zoom(delta: float) -> void:
	var new_zoom = camera.transform.basis.z.normalized() * (zoom_speed * delta * _zoom_direction)
	print(new_zoom)
	new_zoom[1] = clamp(camera.transform.origin.y + new_zoom[1], 
					camera.transform.basis.z.normalized()[1] * min_zoom, 
					camera.transform.basis.z.normalized()[1] * max_zoom)
	new_zoom[2] = clamp(camera.transform.origin.z + new_zoom[2], 
					camera.transform.basis.z.normalized()[2] * min_zoom, 
					camera.transform.basis.z.normalized()[2] * max_zoom)
	print(" " + str(new_zoom))
	camera.transform.origin = new_zoom
	_zoom_direction = 0
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
