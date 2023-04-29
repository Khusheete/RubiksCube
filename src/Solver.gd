extends Node

onready var rubikscube: Spatial = get_tree().root.get_node("/root/Main/RubiksCube")
onready var camera: Camera = get_tree().root.get_node("/root/Main/Camera")
onready var G: Node = get_tree().root.get_node("/root/Global")

var move_seq: RegEx

func _ready():
	move_seq = RegEx.new()
	var _err = move_seq.compile("(?<move>\\w)(?<count>\\d*)(?<dir>'?)")
	

var solving: bool = false
var moving: bool = false

var queued_moves: Array = []

#parses a string in the international notation for the Rubik's Cube moves
#source: https://www.francocube.com/notation
func queue_moves(moves: String):
	var index: int = 0
	
	while index < moves.length():
		if moves[index] == '(':
			var pcount: int = 1
			var substr: String = ""
			index += 1
			while pcount > 0:
				if moves[index] == "(":
					pcount += 1
				elif moves[index] == ")":
					pcount -= 1
				if pcount > 0:
					substr += moves[index]
				index += 1
			var count: int = 1
			if moves[index].is_valid_integer():
				var c: String = ""
				while index < moves.length():
					if !moves[index].is_valid_integer():
						break
					c += moves[index]
					index += 1
				count = int(c)
			for _i in range(count):
				queue_moves(substr)
		else:
			var m: RegExMatch = move_seq.search(moves, index)
			var action: String = m.strings[m.names["move"]]
			var count: int = int(m.strings[m.names["count"]])
			var dir: int = 1 if m.strings[m.names["dir"]].empty() else -1
			
			if count == 0:
				count = 1
			
			for _i in range(count):
				var move: Dictionary = {
					"face": "",
					"dir": dir
				}
				
				
				match action:
					"U":
						move["face"] = "up"
					"D":
						move["face"] = "down"
					"R":
						move["face"] = "right"
					"L":
						move["face"] = "left"
					"F":
						move["face"] = "front"
					"B":
						move["face"] = "back"
					"u":
						if dir == 1:
							queue_moves("yD")
					"r":
						if dir == 1:
							queue_moves("xL")
					"f":
						if dir == 1:
							queue_moves("zB")
					"d":
						if dir == 1:
							queue_moves("y'U")
					"l":
						if dir == 1:
							queue_moves("x'R")
					"b":
						if dir == 1:
							queue_moves("z'F")
					"M":
						if dir == 1:
							queue_moves("L'Rx'")
					"m":
						if dir == 1:
							queue_moves("LR'")
					"E":
						if dir == 1:
							queue_moves("U'Dy")
					"e":
						if dir == 1:
							queue_moves("UD'")
					"S":
						if dir == 1:
							queue_moves("F'Bz")
					"s":
						if dir == 1:
							queue_moves("FB'")
					"x":
						move["face"] = "turnx"
					"y":
						move["face"] = "turny"
					"z":
						move["face"] = "turnz"
				
				if !move["face"].empty():
					queued_moves.append(move)
			
			index += m.strings[0].length() - 1
			
		index += 1

func apply_moves():
	moving = true
	G.set_mouse_mode(G.MouseMode.AUTOMOVE)
	_apply_move()

func stop():
	solving = false
	moving = false
	G.set_mouse_mode(G.MouseMode.CAPTURED)


func _input(event: InputEvent):
	
	if event.is_action_pressed("solve"):
		#reset rubiks cube variable in case of a reset
		rubikscube = get_tree().root.get_node("/root/Main/RubiksCube")
		if !rubikscube.is_connected("completed_move", self, "_rc_completed_move"):
			var _err = rubikscube.connect("completed_move", self, "_rc_completed_move")
		
		queue_moves("(RUE'x)5fDyrze")
		apply_moves()

func _apply_move():
	var ok: bool = true
	if len(queued_moves) == 0:
		moving = false
		if !solving:
			G.set_mouse_mode(G.MouseMode.CAPTURED)
		return
	var next_move: Dictionary = queued_moves.pop_front()
	
	match next_move["face"]:
		"turnx":
			camera.move(Vector3(next_move["dir"] * 90.0, 0.0, 0.0))
			ok = false
		"turny":
			camera.move(Vector3(0.0, next_move["dir"] * 90.0, 0.0))
			ok = false
		"turnz":
			camera.move(Vector3(0.0, 0.0, next_move["dir"] * 90.0))
			ok = false
	
	if ok:
		rubikscube.queue_move(next_move["face"], next_move["dir"], 0.1)
	else:
		_apply_move()
	
func _rc_completed_move():
	if moving:
		_apply_move()
