extends Spatial

signal completed_move()

onready var G = get_node("/root/Global")

var front: Array
var back: Array
var up: Array
var down: Array
var left: Array
var right: Array

var cubies: Array

var moves: Array = []
var moving: bool = false
var move_data: Dictionary


var spacing: float = 1.02



func _ready():
	var Cubie = preload("res://src/objects/Cubie.tscn")
	
	#generate all cubies
	for i in range(-1, 2):
		for j in range(-1, 2):
			for k in range(-1, 2):
				if i == 0 && j == 0 && k == 0:
					continue
				#create cubie
				var cubie = Cubie.instance()
				add_child(cubie)
				
				cubie.translate(Vector3(i * spacing, j * spacing, k * spacing))
				cubie.pos = Vector3(i, j, k)
				
				if i >= 0:
					cubie.set_color("x-", G.Colors.BLACK)
				if i <= 0:
					cubie.set_color("x+", G.Colors.BLACK)
				
				if j >= 0:
					cubie.set_color("y-", G.Colors.BLACK)
				if j <= 0:
					cubie.set_color("y+", G.Colors.BLACK)
				
				if k >= 0:
					cubie.set_color("z-", G.Colors.BLACK)
				if k <= 0:
					cubie.set_color("z+", G.Colors.BLACK)
				
				cubies.append(cubie)
	
	update_cubie_groups()



func _process(delta: float):
	if !moving && len(moves) > 0: #setup the next move
		set_glow("") # reset glow
		move_data = moves.pop_front()
		move_data.progress = 0
		moving = true
		$Moving.rotation = Vector3(0, 0, 0)
		
		match move_data.id.to_lower():
			"x+", "front", "f":
				for c in front:
					remove_child(c)
					$Moving.add_child(c)
				move_data.dir *= -1
				move_data.normal = Vector3(1, 0, 0) * move_data.dir
			"x-", "back", "b":
				for c in back:
					remove_child(c)
					$Moving.add_child(c)
				move_data.normal = Vector3(1, 0, 0) * move_data.dir
			"y+", "up", "u":
				for c in up:
					remove_child(c)
					$Moving.add_child(c)
				move_data.dir *= -1
				move_data.normal = Vector3(0, 1, 0) * move_data.dir
			"y-", "down", "d":
				for c in down:
					remove_child(c)
					$Moving.add_child(c)
				move_data.normal = Vector3(0, 1, 0) * move_data.dir
			"z+", "left", "l":
				for c in left:
					remove_child(c)
					$Moving.add_child(c)
				move_data.dir *= -1
				move_data.normal = Vector3(0, 0, 1) * move_data.dir
			"z-", "right", "r":
				for c in right:
					remove_child(c)
					$Moving.add_child(c)
				move_data.normal = Vector3(0, 0, 1) * move_data.dir
	
	if moving: #do the current move
		move_data.progress += delta
		if move_data.progress > move_data.duration:
			#if finished, reset all cubies in place
			#the transform will be removed
			moving = false
			for c in $Moving.get_children():
				$Moving.remove_child(c)
				add_child(c)
			
			#apply the move to the cubies (colors)
			_apply_move(move_data.id, move_data.dir)
		else:
			#rotate
			$Moving.rotate(move_data.normal, PI * 0.5 * delta / move_data.duration)




const SPIRAL: Array = [[-1, -1], [0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0]]

func _apply_move(id: String, direction: int):
	match id.to_lower():
		"x+", "front", "f":
			for c in front:
				c.rotate_faces("x", direction)
			for _i in range(2):
				for index in range(0, 7):
					var i0: int = SPIRAL[index][0]
					var j0: int = SPIRAL[index][1]
					var i1: int = SPIRAL[index - 1 if index != 0 else 7][0]
					var j1: int = SPIRAL[index - 1 if index != 0 else 7][1]
					
					#get cubies
					var c0: Spatial = get_cubie(1, i0, j0)
					var c1: Spatial = get_cubie(1, i1, j1)
					
					_switch_pos(c0, c1)
					
		"x-", "back", "b":
			for c in back:
				c.rotate_faces("x", direction)
			for _i in range(2):
				for index in range(0, 7):
					var i0: int = SPIRAL[index][0]
					var j0: int = SPIRAL[index][1]
					var i1: int = SPIRAL[index - 1 if index != 0 else 7][0]
					var j1: int = SPIRAL[index - 1 if index != 0 else 7][1]
					
					#get cubies
					var c0: Spatial = get_cubie(-1, i0, j0)
					var c1: Spatial = get_cubie(-1, i1, j1)
					
					_switch_pos(c0, c1)
		"y+", "up", "u":
			for c in up:
				c.rotate_faces("y", direction)
			for _i in range(2):
				for index in range(7, 0, -1):
					var i0: int = SPIRAL[index][0]
					var j0: int = SPIRAL[index][1]
					var i1: int = SPIRAL[index + 1 if index < 7 else 0][0]
					var j1: int = SPIRAL[index + 1 if index < 7 else 0][1]
					
					#get cubies
					var c0: Spatial = get_cubie(i0, 1, j0)
					var c1: Spatial = get_cubie(i1, 1, j1)
					
					_switch_pos(c0, c1)
		"y-", "down", "d":
			for c in down:
				c.rotate_faces("y", direction)
			for _i in range(2):
				for index in range(7, 0, -1):
					var i0: int = SPIRAL[index][0]
					var j0: int = SPIRAL[index][1]
					var i1: int = SPIRAL[index + 1 if index < 7 else 0][0]
					var j1: int = SPIRAL[index + 1 if index < 7 else 0][1]
					
					#get cubies
					var c0: Spatial = get_cubie(i0, -1, j0)
					var c1: Spatial = get_cubie(i1, -1, j1)
					
					_switch_pos(c0, c1)
		"z+", "left", "l":
			for c in left:
				c.rotate_faces("z", direction)
			for _i in range(2):
				for index in range(0, 7):
					var i0: int = SPIRAL[index][0]
					var j0: int = SPIRAL[index][1]
					var i1: int = SPIRAL[index - 1 if index != 0 else 7][0]
					var j1: int = SPIRAL[index - 1 if index != 0 else 7][1]
					
					#get cubies
					var c0: Spatial = get_cubie(i0, j0, 1)
					var c1: Spatial = get_cubie(i1, j1, 1)
					
					_switch_pos(c0, c1)
		"z-", "right", "r":
			for c in right:
				c.rotate_faces("z", direction)
			for _i in range(2):
				for index in range(0, 7):
					var i0: int = SPIRAL[index][0]
					var j0: int = SPIRAL[index][1]
					var i1: int = SPIRAL[index - 1 if index != 0 else 7][0]
					var j1: int = SPIRAL[index - 1 if index != 0 else 7][1]
					
					#get cubies
					var c0: Spatial = get_cubie(i0, j0, -1)
					var c1: Spatial = get_cubie(i1, j1, -1)
					
					_switch_pos(c0, c1)
	
	if direction == -1: #the inverse move is equivalent to three times this move
		#so apply it 2 more times
		_apply_move(id, 0)
		_apply_move(id, 0)
	
	if direction != 0:
		update_cubie_groups()
		emit_signal("completed_move")


func update_cubie_groups():
	#reset all groups
	front = []
	back = []
	up = []
	down = []
	left = []
	right = []
	
	#reset names
	for cubie in cubies:
		cubie.name = "temp_name"
	
	for cubie in cubies:
		var i: int = int(sign(cubie.pos.x))
		var j: int = int(sign(cubie.pos.y))
		var k: int = int(sign(cubie.pos.z))
		cubie.name = get_cubie_name(i, j, k)
		
		if i > 0:
			front.append(cubie)
		elif i < 0:
			back.append(cubie)
		
		if j > 0:
			up.append(cubie)
		elif j < 0:
			down.append(cubie)
		
		if k > 0:
			left.append(cubie)
		elif k < 0:
			right.append(cubie)



func get_cubie_name(x: int, y: int, z: int) -> String:
	var name: String = "+" if x > 0 else "-" if x < 0 else "0"
	name += "+" if y > 0 else "-" if y < 0 else "0"
	name += "+" if z > 0 else "-" if z < 0 else "0"
	return name



func get_cubie(x: int, y: int, z: int) -> Node:
	return get_node(get_cubie_name(x, y, z))



#adds a move to the queue
func queue_move(id: String, direction: int, duration: float):
	moves.append({
		"id": id, 
		"dir": sign(direction),
		"duration": duration
	})

func get_color(direction: String, x: int, y: int) -> int:
	match direction:
		"x+", "front", "f":
			return get_cubie(1, x, y).get_color(direction)
		"x-", "back", "b":
			return get_cubie(-1, x, y).get_color(direction)
		"y+", "up", "u":
			return get_cubie(x, 1, y).get_color(direction)
		"y-", "down", "d":
			return get_cubie(x, -1, y).get_color(direction)
		"z+", "left", "l":
			return get_cubie(x, y, 1).get_color(direction)
		"z-", "right", "r":
			return get_cubie(x, y, -1).get_color(direction)
	return 6
	

func _switch_pos(cubie0: Node, cubie1: Node):
	var tmp: Vector3 = cubie0.translation
	cubie0.translation = cubie1.translation
	cubie1.translation = tmp
	tmp = cubie0.pos
	cubie0.pos = cubie1.pos
	cubie1.pos = tmp


func set_glow(id: String):
	if moving:
		return
	
	for c in cubies:
		c.glow = false
	match id:
		"x+", "front":
			for c in front:
				c.glow = true
		"x-", "back":
			for c in back:
				c.glow = true
		"y+", "up":
			for c in up:
				c.glow = true
		"y-", "down":
			for c in down:
				c.glow = true
		"z+", "left":
			for c in left:
				c.glow = true
		"z-", "right":
			for c in right:
				c.glow = true


