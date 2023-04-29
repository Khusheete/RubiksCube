extends Node

enum MouseMode {
	CAPTURED,
	FREE,
	AUTOMOVE
}

var mouse_mode: int setget , get_mouse_mode

enum Colors {
	RED,
	ORANGE,
	WHITE,
	YELLOW,
	GREEN,
	BLUE,
	BLACK
}

const COLORS: Array = [
	Color(.8, 0, 0),
	Color(.8, .5, 0),
	Color(.8, .8, .8),
	Color(.8, .8, 0),
	Color(0, .8, 0),
	Color(0, 0, .8),
	Color(0, 0, 0)
]

func _ready():
	set_mouse_mode(MouseMode.CAPTURED)

func set_mouse_mode(mode: int):
	match mode:
		MouseMode.CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		MouseMode.FREE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		MouseMode.AUTOMOVE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	mouse_mode = mode


func _input(event: InputEvent):
	
	if event is InputEventMouseMotion:
		if mouse_mode == MouseMode.CAPTURED:
			Input.warp_mouse_position(OS.get_real_window_size() / 2)
	
	if event.is_action_pressed("ui_cancel"):
		match mouse_mode:
			MouseMode.CAPTURED:
				set_mouse_mode(MouseMode.FREE)
			MouseMode.FREE:
				set_mouse_mode(MouseMode.CAPTURED)



func get_mouse_mode() -> int:
	return mouse_mode
