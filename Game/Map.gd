extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for y in range(0, 100):
		for x in range(0, 100):
			set_cell(x, y, 0)

func resetGrid():
	for y in range(0, 100):
		for x in range(0, 100):
			set_cell(x, y, 0)

func setTerrain(terrain_type, pos_dict):
	var cell = 0
	if (terrain_type == "building"):
		cell = 1
	elif (terrain_type == "rock"):
		cell = 2
	elif (terrain_type == "tree"):
		cell = 3
	set_cell(pos_dict["x"], pos_dict["y"], cell)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
