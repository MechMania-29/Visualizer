extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "river"
var health = -1
var id = "err"
var has_fish = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if (randi() % 20 == 0):
		has_fish = true
	play("river-1")
	pass # Replace with function body.

func set_status(new_type, new_health, new_id=null):
	if (new_id != null):
		id = new_id
	health = new_health
	type = new_type
	if (type == "river" and has_fish):
		type = "riverfish"
	play(type+str(health))
	show()

func get_status():
	if type == "riverfish":
		return ["river", health, id]
	return [type, health, id]

func hurt(damage):
	if (health == -1):
		return
	health -= damage
	if (health < 0):
		health = 0
	else:
		play(type + str(health))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
