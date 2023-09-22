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
		for id in terrain_dict[pos]:
			terrain_dict[pos][id].hide()

func setTerrain(terrain_type, health, pos_dict, id):
	var pos = Vector2(pos_dict['x'], pos_dict['y'])
	if !terrain_dict.has(pos):
		terrain_dict[pos] = {}
	if !terrain_dict[pos].has(id):
		var new_terrain = terrain_sprite.instance()
		new_terrain.position = pos * Global.BOARD_TILESIZE
		self.add_child(new_terrain)
		terrain_dict[pos][id] = new_terrain
	terrain_dict[pos][id].set_status(terrain_type, health, id)
	if terrain_dict[pos].size() > 1:
		var has_terrain = false
		for id_iter in terrain_dict[pos]:
			if (terrain_dict[pos][id_iter].health != 0):
				has_terrain = true
				break
		if (has_terrain):
			for id_iter in terrain_dict[pos]:
				if (terrain_dict[pos][id_iter].health == 0):
					terrain_dict[pos][id_iter].hide()

func hurtTerrain(pos, damage, id):
	if !terrain_dict.has(pos) or !terrain_dict[pos].has(id):
		return
	terrain_dict[pos][id].hurt(damage)

func getTerrain(pos):
	if !terrain_dict.has(pos):
		return null
	else:
		for id in terrain_dict[pos]:
			if (terrain_dict[pos][id].health != 0):
				return terrain_dict[pos][id].get_status()
	return null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
