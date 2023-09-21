extends AnimatedSprite

#signal done_moving

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var tween = $Tween
const TILESIZE = Global.BOARD_TILESIZE
const XOFFSET = Global.BOARD_X_OFFSET
const YOFFSET = Global.BOARD_Y_OFFSET
const MOVETIME = Global.TOTAL_TURN_TIME/5.0
var isZombie = false
var my_class = "NORMAL"
var converting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.material = self.material.duplicate()
	self.play(getAnimPrefix() + "I")
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
	if (abs(x_dist) + abs(y_dist) > 0):
		self.play(getAnimPrefix()+"I")

# NOTE: y_dist refers to distance in tiles
func moveY(y_dist):
	var y_time = MOVETIME/2
	
	if tween.interpolate_property(self, 'position', 
		position, Vector2(self.position.x, y_dist * TILESIZE + self.position.y), y_time, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			tween.start()

# NOTE: x_dist refers to distance in tiles
func moveX(x_dist):
	var x_time = MOVETIME/2
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
	self.play(getAnimPrefix() + "A")
	if (target.x > self.position.x):
		self.flip_h = false
	elif (target.x < self.position.x):
		self.flip_h = true
	if ((target - self.position).length_squared() > 0):
		if (isZombie):
			$AttackArrow.modulate = Color(0,.5,0)
		else:
			$AttackArrow.modulate = Color(.1,.1,.1)
		$AttackArrow.rotation = (target-self.position).angle() + PI/2
		$AttackArrow.show()

func resetArrows():
	$AttackArrow.hide()
	$ActionArrow.hide()

func setClass(cl):
	my_class = cl
	if (cl == "BUILDER"):
		$ActionArrow.modulate = Color("fcba03")
	elif (cl == "MEDIC"):
		$ActionArrow.modulate = Color("ff6661")
	self.play(getAnimPrefix()+"I")

func setIsZombie(is_zombie, now_converting=false):
	converting = now_converting
	isZombie = is_zombie
	self.play(getAnimPrefix() + "I")
	#self.play(my_color + my_class + "H")

func hurt():
	self.material.set_shader_param("enabled", true)
	yield(get_tree().create_timer(Global.TOTAL_TURN_TIME/15),"timeout")
	self.material.set_shader_param("enabled", false)
	if (isZombie):
		self.play("ZS")

func stun(is_stunned):
	if (!isZombie or converting):
		return
	if (is_stunned):
		self.play("ZS")
	else:
		self.play("ZI")

func die():
	converting = true
	isZombie = true
	self.play(getAnimPrefix(false) + "D")

func ability(target):
	if (my_class == "MEDIC" or my_class == "BUILDER"):
		self.play(getAnimPrefix(false) + "A")
		if ((target - self.position).length_squared() > 0):
			$ActionArrow.rotation = (target-self.position).angle() + PI/2
			$ActionArrow.show()

func getAnimPrefix(checkZombie=true):
	if (isZombie and checkZombie) or my_class == "ZOMBIE":
		return "Z"
	if (my_class == "MEDIC"):
		return "Me"
	return my_class[0]

func _on_Tween_tween_completed(object, key):
	#self.play(my_color + my_class + "I")
	pass
