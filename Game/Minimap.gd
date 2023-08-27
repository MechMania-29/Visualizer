extends TextureRect

const dot_size = 2
var board = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#self.position = Vector2(0, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	if (board is Dictionary):
		for c_id in board:
			var character = board[c_id]
			if character["isZombie"]:
				add_rect(Vector2(character["position"]["x"], character["position"]["y"]), Color.green)
			else:
				add_rect(Vector2(character["position"]["x"], character["position"]["y"]), Color.black)
				

func add_dot(pos, color):
	draw_primitive(PoolVector2Array([pos]), PoolColorArray([color]), PoolVector2Array([pos]))

func add_rect(pos, color):
	draw_rect(Rect2(pos*2, Vector2(2, 2)), color)
