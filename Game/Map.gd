extends Sprite

var grid_size = 100
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var terrain_sprite = preload("res://Game/Terrain.tscn")
var terrain_dict = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	resetGrid()

func updateGridSize(new_size):
	grid_size = new_size
	resetGrid()

func resetGrid():
	for pos in terrain_dict:
		terrain_dict[pos].hide()

#TODO update with new terrains
func setTerrain(terrain_type, health, pos_dict):
	var pos = Vector2(pos_dict['x'], pos_dict['y'])
	if !terrain_dict.has(pos):
		var new_terrain = terrain_sprite.instance()
		new_terrain.position = pos * Global.BOARD_TILESIZE
		self.add_child(new_terrain)
		terrain_dict[pos] = new_terrain
	terrain_dict[pos].set_status(terrain_type, health)

func getTerrain(pos):
	if !terrain_dict.has(pos):
		return null
	else:
		return terrain_dict[pos].get_status()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
