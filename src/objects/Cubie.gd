extends Spatial

onready var G = get_node("/root/Global")


var color: Array = [0, 0, 0, 0, 0, 0]
var pos: Vector3

var glow: bool = false setget set_glow, get_glow

func _ready():
	set_color("x+", G.Colors.RED)
	set_color("x-", G.Colors.ORANGE)
	set_color("y+", G.Colors.WHITE)
	set_color("y-", G.Colors.YELLOW)
	set_color("z+", G.Colors.GREEN)
	set_color("z-", G.Colors.BLUE)
	

func get_color(id: String) -> int:
	match id.to_lower():
		"x+", "front", "f":
			return color[0]
		"x-", "back", "b":
			return color[1]
		"y+", "up", "u":
			return color[2]
		"y-", "down", "d":
			return color[3]
		"z+", "left", "l":
			return color[4]
		"z-", "right", "r":
			return color[5]
	return -1


func set_color(id: String, value: int):
	match id.to_lower():
		"x+", "front", "f":
			color[0] = value
			$"X+".material_override.albedo_color = G.COLORS[value]
		"x-", "back", "b":
			color[1] = value
			$"X-".material_override.albedo_color = G.COLORS[value]
		"y+", "up", "u":
			color[2] = value
			$"Y+".material_override.albedo_color = G.COLORS[value]
		"y-", "down", "d":
			color[3] = value
			$"Y-".material_override.albedo_color = G.COLORS[value]
		"z+", "left", "l":
			color[4] = value
			$"Z+".material_override.albedo_color = G.COLORS[value]
		"z-", "right", "r":
			color[5] = value
			$"Z-".material_override.albedo_color = G.COLORS[value]


func rotate_faces(axis: String, direction: int):
	if direction == 0:
		return
	
	match axis.to_lower():
		"x":
			var tmp: int = get_color("y+")
			set_color("y+", get_color("z-"))
			set_color("z-", get_color("y-"))
			set_color("y-", get_color("z+"))
			set_color("z+", tmp)
		"y":
			var tmp: int = get_color("z+")
			set_color("z+", get_color("x-"))
			set_color("x-", get_color("z-"))
			set_color("z-", get_color("x+"))
			set_color("x+", tmp)
		"z":
			var tmp: int = get_color("y+")
			set_color("y+", get_color("x+"))
			set_color("x+", get_color("y-"))
			set_color("y-", get_color("x-"))
			set_color("x-", tmp)
	
	if direction == -1:
		rotate_faces(axis, 1)
		rotate_faces(axis, 1)


func set_glow(g: bool):
	glow = g
	for c in get_children():
		c.layers = 2 if glow else 1


func get_glow() -> bool:
	return glow


