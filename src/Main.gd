extends Spatial

var POSSIBLE_MOVES: Array = ["x+", "x-", "y+", "y-", "z+", "z-"]
var Rubikscube = preload("res://src/objects/RubiksCube.tscn")
onready var G: Node = get_tree().root.get_node("/root/Global")

func _process(_delta: float):
	#set glow
	var face = "front"
	if Input.is_action_pressed("ui_up"):
		face = "up"
	elif Input.is_action_pressed("ui_down"):
		face = "down"
	elif Input.is_action_pressed("ui_left"):
		face = "left"
	elif Input.is_action_pressed("ui_right"):
		face = "right"
	elif Input.is_action_pressed("ui_back"):
		face = "back"
	
	$RubiksCube.set_glow($Camera.get_absolute_face_id(face))
	

func _input(event: InputEvent):
	
	if event.is_action_pressed("reset"):
		
		if G.mouse_mode == G.MouseMode.AUTOMOVE:
			get_tree().root.get_node("/root/Solver").stop()
		
		get_node("RubiksCube").queue_free()
		remove_child(get_node("RubiksCube"))
		var rc = Rubikscube.instance()
		add_child(rc)
		rc.name = "RubiksCube"
	
	if G.mouse_mode == G.MouseMode.AUTOMOVE:
		return
	
	
	var direction: int = 0
	
	if event.is_action_pressed("+dir"):
		direction = 1
	elif event.is_action_pressed("-dir"):
		direction = -1
	
	if direction != 0:
		var face = "front"
		if Input.is_action_pressed("ui_up"):
			face = "up"
		elif Input.is_action_pressed("ui_down"):
			face = "down"
		elif Input.is_action_pressed("ui_left"):
			face = "left"
		elif Input.is_action_pressed("ui_right"):
			face = "right"
		elif Input.is_action_pressed("ui_back"):
			face = "back"
		
		get_node("RubiksCube").queue_move($Camera.get_absolute_face_id(face), direction, .5)
	
	
	if event.is_action_pressed("random"):
		for _i in range(200):
			get_node("RubiksCube").queue_move(POSSIBLE_MOVES[int(rand_range(0, 6))], 1, .02)


