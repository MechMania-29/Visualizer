extends Node2D

signal forced_pause(paused)
signal restart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var UI = $"../CanvasLayer/UI"
onready var T_Map = $"../TileMap"
onready var actor = preload("res://Game/Player.tscn")

var turn = 0
var gamelog
var turns
var actors = []
var ready = false
var timeline_clicked = false
var terrain = []

var info_coord = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func updateInfoCoord(target):
	if (target != null):
		info_coord = target
	var character_dict = turns[turn]["characters"]
	var str_out = ""
	for i in range(len(actors)):
		if (character_dict[str(i)]['position']['x'] == info_coord.x and character_dict[str(i)]['position']['y'] == info_coord.y):
			if (character_dict[str(i)]['isZombie']):
				str_out += "Zombie"
				if (character_dict[str(i)]['isStunned']):
					str_out += ", stunned"
			else:
				str_out += "Human, "
				# add class here
				str_out += str(character_dict[str(i)]['health']) + " health"
			str_out += "\n"
	
	var terr = $"../TileMap".getTerrain(info_coord)
	if terr != null:
		if terr[1] == -1:
			str_out += terr[0]
		else:
			str_out += terr[0] + ", " + str(terr[1]) + " health"
	
	UI.update_info_box(str_out, info_coord)


func reset():
	UI.update_turn_num(0)
	jumpToTurn(0)
	nextTurn()

func nextTurn():
	turn += 1
	$TurnTimer.start(1)
	if ready:
		UI.update_turn_num(turn)
		#print(terrain[turn])
		
		UI.update_minimap(turns[turn]["characters"])
		
		T_Map.resetGrid()
		
		var character_dict = turns[turn]["characters"]
		var zleft = 0
		var hleft = 0
		for i in range(len(actors)):
			actors[i].moveTo(character_dict[str(i)]["position"])
			if character_dict[str(i)]["isZombie"]:
				zleft+=1
			else:
				hleft+=1
			actors[i].setIsZombie(character_dict[str(i)]["isZombie"])
			if character_dict[str(i)].has("attackAction") and character_dict[str(i)]["attackAction"] != null:
				var attackedID = character_dict[str(i)]["attackAction"]["attackingId"]
				
				if character_dict[str(i)]["attackAction"]["type"] == "TERRAIN": 
					#print(terrain[turn][attackedID], attackedID)
					var pos = Vector2(terrain[turn][attackedID]["position"]["x"], terrain[turn][attackedID]["position"]["y"])
					pos.x = pos.x*Global.BOARD_TILESIZE + Global.BOARD_X_OFFSET
					pos.y = pos.y*Global.BOARD_TILESIZE + Global.BOARD_Y_OFFSET
					actors[i].attack(pos)
				elif character_dict[str(i)]["attackAction"]["type"] == "CHARACTER":
					actors[i].attack(actors[int(attackedID)].position)
					if character_dict[attackedID]["health"] == 0:
						actors[int(attackedID)].die()
					else:
						actors[int(attackedID)].hurt()
		
		UI.update_num_left(zleft, hleft)
		updateInfoCoord(null)
		
		for t_key in terrain[turn]:
			if (!terrain[turn][t_key]["destroyed"]):
				T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["health"], terrain[turn][t_key]["position"])
		
		
		
		if turn >= len(turns)-1:
			UI.force_pause(true)
			$TurnTimer.set_paused(true)


func jumpToTurn(new_turn):
	if (ready):
		turn = new_turn
		UI.update_turn_num(turn)
		
		UI.update_minimap(turns[turn]["characters"])
		
		T_Map.resetGrid()
		for t_key in terrain[turn]:
			if (!terrain[turn][t_key]["destroyed"]):
				T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["health"], terrain[turn][t_key]["position"])
		
		var zleft = 0
		var hleft = 0
		for i in range(len(actors)):
			actors[i].instantMoveTo(turns[turn]["characters"][str(i)]["position"])
			actors[i].setIsZombie(turns[turn]["characters"][str(i)]["isZombie"])
			if turns[turn]["characters"][str(i)]["isZombie"]:
				zleft+=1
			else:
				hleft+=1
			if (turns[turn]["characters"][str(i)]["isZombie"]):
				actors[i].stun(turns[turn]["characters"][str(i)]["isStunned"])
			elif (turns[turn]["characters"][str(i)]["health"] == 0):
				actors[i].die()
		UI.update_num_left(zleft, hleft)
		updateInfoCoord(null)
		
		if new_turn >= len(turns)-1:
			UI.force_pause(true)
			$TurnTimer.set_paused(true)


# Handling the timer
func _on_Timer_timeout():
	if (turn >= len(turns) - 1):
		reset()
	else:
		nextTurn()

func _on_UI_pause_toggled(playing):
	if playing:
		_on_Timer_timeout()
		$TurnTimer.set_paused(false)
	else:
		$TurnTimer.set_paused(true)

func _on_UI_timeline_changed(value):
	if (timeline_clicked):
		jumpToTurn(value)

func _on_UI_timeline_interaction(clicked):
	timeline_clicked = clicked
	if clicked:
		UI.force_pause(true)


#func _on_FileSelect_file_loaded(new_gamelog, names):
	#pass
	#turn = 0
	#gamelog = new_gamelog
	#ready = true
	#turns = gamelog["GameLog"]["Main"]["Turns"]
	#turns = gamelog
	#for i in len(players):
	#	#players[i].instantMoveTo(turns[0]["Players"][i]["Position"])
	#	players[i].instantMoveTo(turns[0]["player_states"][i]["position"])
	#	players[i].updateClass(turns[0]["player_states"][i]["class"][0].capitalize())
	#	#players[i].move_time_unit = move_time
	#	#players[i].my_color = "Red" #TEST
	#	players[i].visible = true
	#UI.update_player_stats(turns[0]["player_states"])
	#UI.end_turn_update_player_stats(turns[0]["player_states"])
	#UI.update_names(names)
	#UI.change_max_turns(len(turns))
	#$Logo.visible = false
	#$TurnTimer.start()
	#$TurnTimer.set_paused(false)
	#nextTurn()

	
func startup(new_gamelog, new_terrain):
	gamelog = new_gamelog
	terrain = new_terrain
	
	# create actors
	for i in range(gamelog["setup"]["totalCharacters"]):
		var new_actor = actor.instance()
		get_parent().add_child(new_actor)
		actors.push_back(new_actor)
	
	# populate terrain
	if false:
		for i in range(gamelog["stats"]["turns"]+1):
			if (i > 0):
				terrain.append(terrain[i-1].duplicate())
			else:
				terrain.append({})
			for t_key in gamelog["turns"][i]["terrain"]:
				if terrain[i].has(t_key):
					for update_key in gamelog["turns"][i]["terrain"][t_key]:
						terrain[i][t_key][update_key] = gamelog["turns"][i]["terrain"][t_key][update_key]
				else:
					terrain[i][t_key] = gamelog["turns"][i]["terrain"][t_key]
	
	# populate characters
	if false:
		for i in range(1, len(gamelog["turns"])):
			for a in range(len(actors)):
				if (!gamelog["turns"][i]["characters"].has(str(a))):
					gamelog["turns"][i]["characters"][str(a)] = {}
				for c_key in gamelog["turns"][i-1]["characters"][str(a)]:
					if (!gamelog["turns"][i]["characters"][str(a)].has(c_key)):
						gamelog["turns"][i]["characters"][str(a)][c_key] = gamelog["turns"][i-1]["characters"][str(a)][c_key]
			#	if (!gamelog["turns"][i]["characters"][str(a)].has("isZombie")):
			#		gamelog["turns"][i]["characters"][str(a)]["isZombie"] = gamelog["turns"][i-1]["characters"][str(a)]["isZombie"]
	turns = gamelog["turns"]
	
	var board_size = gamelog["setup"]["boardSize"]
	T_Map.updateGridSize(board_size)

	for t_key in terrain[0]:
		T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["health"], terrain[turn][t_key]["position"])
	
	for i in range(gamelog["setup"]["totalCharacters"]):
		actors[i].instantMoveTo(gamelog["turns"][0]["characters"][str(i)]["position"])
		actors[i].setIsZombie(gamelog["turns"][0]["characters"][str(i)]["isZombie"])
	
	# Set up UI
	UI.change_max_turns(gamelog["stats"]["turns"])
	UI.update_score(gamelog["scores"]["zombies"], gamelog["scores"]["humans"])
	#UI.update_num_left(gamelog["stats"]["zombiesLeft"], gamelog["stats"]["humansLeft"])
	UI.show()
	
	ready = true
	nextTurn()


func _on_FileSelect_file_loaded(GameLog, Terrain):
	#var save_game = File.new()
	#save_game.open("user://savegame2.save", File.WRITE)
	#save_game.store_line(str(GameLog))
	#save_game.close()
	
	startup(GameLog, Terrain)
