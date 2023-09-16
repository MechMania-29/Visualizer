extends AnimatedSprite

#signal done_moving

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var tween = $Tween
const TILESIZE = Global.BOARD_TILESIZE
const XOFFSET = Global.BOARD_X_OFFSET
const YOFFSET = Global.BOARD_Y_OFFSET
var status = "N"
# Called when the node enters the scene tree for the first time.
func _ready():
	self.material = self.material.duplicate()
	self.play(status + "I")
	pass
	
# H = hurt, D = die, AH = Attack horizontally, I = Idle, W = walking

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func moveTo(pos_dict):
	var new_pos = [pos_dict['x'], pos_dict['y']]
	var y_dist = new_pos[1] - ((self.position.y - YOFFSET) / TILESIZE)
	if (abs(y_dist) > 0):
		moveY(y_dist)
		yield(tween, "tween_completed")
	
	var x_dist = new_pos[0] - ((self.position.x - XOFFSET) / TILESIZE)
	if (abs(x_dist) > 0):
		moveX(x_dist)
		yield(tween, "tween_completed")
	#emit_signal("done_moving")
	self.play(status+"I")
	
# NOTE: y_dist refers to distance in tiles
func moveY(y_dist):
	var y_time = .05
	
	if tween.interpolate_property(self, 'position', 
		position, Vector2(self.position.x, y_dist * TILESIZE + self.position.y), y_time, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			tween.start()

# NOTE: x_dist refers to distance in tiles
func moveX(x_dist):
	var x_time = .05
	
	if tween.interpolate_property(self, 'position', 
		position, Vector2(x_dist * TILESIZE + self.position.x, self.position.y), x_time, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			tween.start()
			if x_dist < 0:
				self.flip_h = true
			else:
				self.flip_h = false


func instantMoveTo(pos_dict):
	var new_pos = [pos_dict['x'], pos_dict['y']]
	self.position = Vector2((new_pos[0]*TILESIZE) + XOFFSET, (new_pos[1]*TILESIZE) + YOFFSET)
	tween.stop_all()

func attack(target: Vector2):
	self.play(status + "A")
	if (target.x > self.position.x):
		self.flip_h = false
	elif (target.x < self.position.x):
		self.flip_h = true

func setClass(cl):
	status = cl
	self.play(cl+"I")

func setIsZombie(is_zombie):
	if (is_zombie):
		status = "Z"
	else:
		status = "N"
	self.play(status + "I")
	#self.play(my_color + my_class + "H")

func hurt():
	self.material.set_shader_param("enabled", true)
	yield(get_tree().create_timer(1),"timeout")
	self.material.set_shader_param("enabled", false)
	if (status == "Z"):
		self.play("ZS")

func stun(is_stunned):
	if (is_stunned):
		self.play("ZS")
	else:
		(self.play("ZI"))

func die():
	self.play(status + "D")

func ability():
	if (status == "Me" || status == "B"):
		self.play(status + "A")


func _on_Tween_tween_completed(object, key):
	#self.play(my_color + my_class + "I")
	pass
