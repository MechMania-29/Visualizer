extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "river"
var health = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	play("river-1")
	pass # Replace with function body.

func set_status(new_type, new_health):
	health = new_health
	type = new_type
	play(new_type+str(new_health))
	show()
func get_status():
	return [type, health]

func hurt():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
