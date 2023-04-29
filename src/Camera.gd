extends Camera

onready var G = get_node("/root/Global")

export var dist: float = 8


var joy_threashold: float = .4
#var direction: String = "front"

func _process(_delta: float):
	
	var joy: Vector3 = Vector3(Input.get_joy_axis(0, JOY_AXIS_1), Input.get_joy_axis(0, JOY_AXIS_0), -Input.get_joy_axis(0, JOY_AXIS_2))
	
	if joy.length_squared() > joy_threashold * joy_threashold:
		move(joy * 1.4)


func _input(event: InputEvent):
	
	if event is InputEventMouseMotion && G.mouse_mode == G.MouseMode.CAPTURED:
		var force: Vector2 = event.relative / 10
		move(Vector3(force.y, force.x, 0.0))
	
	if event is InputEventMouseButton && G.mouse_mode == G.MouseMode.CAPTURED:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				move(Vector3(0.0, 0.0, 10.0))
			elif event.button_index == BUTTON_WHEEL_DOWN:
				move(Vector3(0.0, 0.0, -10.0))
		



func move(force: Vector3):
	rotate(transform.basis.x.normalized(), deg2rad(force.x))
	rotate(transform.basis.y.normalized(), deg2rad(force.y))
	rotate(transform.basis.z.normalized(), deg2rad(force.z))

	var phi: float = PI * 0.5 - rotation.y
	var theta: float = rotation.x + PI * 0.5

	var dir: Vector3 = Vector3(sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi))

	translation = dist * dir
	
	
	#sync camera position and rotation
	get_node("../ViewportContainer/Viewport/Camera").translation = translation
	get_node("../ViewportContainer/Viewport/Camera").rotation = rotation


func get_absolute_face_id(relative_id: String) -> String:
	var dir = Vector3.ZERO
	match relative_id:
		"front":
			dir = transform.basis.z.normalized()
		"back":
			dir = -transform.basis.z.normalized()
		"up":
			dir = transform.basis.y.normalized()
		"down":
			dir = -transform.basis.y.normalized()
		"right":
			dir = transform.basis.x.normalized()
		"left":
			dir = -transform.basis.x.normalized()
	
	var dirc: Vector3

	if abs(dir.x) > abs(dir.y) && abs(dir.x) > abs(dir.z):
		dirc = Vector3(round(dir.x), 0, 0)
	elif abs(dir.y) > abs(dir.x) && abs(dir.y) > abs(dir.z):
		dirc = Vector3(0, round(dir.y), 0)
	elif abs(dir.z) > abs(dir.y) && abs(dir.z) > abs(dir.x):
		dirc = Vector3(0, 0, round(dir.z))

	match dirc:
		Vector3(1, 0, 0):
			return "front"
		Vector3(-1, 0, 0):
			return "back"
		Vector3(0, 1, 0):
			return "up"
		Vector3(0, -1, 0):
			return "down"
		Vector3(0, 0, 1):
			return "left"
		Vector3(0, 0, -1):
			return "right"
	
	return ""









