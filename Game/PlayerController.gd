extends Node2D

signal forced_pause(paused)
signal restart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var UI = $"../CanvasLayer/UI"
onready var T_Map = $"../TileMap"
# ["Blue ", "Green ", "Red ", "Purple "]
var turn = 0
var gamelog
var turns
var actors = []
var ready = false
var timeline_clicked = false
var terrain = []
onready var actor = preload("res://Game/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func reset():
	UI.update_turn_num(0)
	jumpToTurn(0)
	nextTurn()

func nextTurn():
	turn += 1
	UI.update_turn_num(turn)
	$TurnTimer.start(1)
	if ready:
		T_Map.resetGrid()
		for i in range(len(actors)):
			actors[i].moveTo(turns[turn]["characters"][str(i)]["position"])
			actors[i].setIsZombie(turns[turn]["characters"][str(i)]["isZombie"])
		for t_key in terrain[turn]:
			T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["position"])
		
		if turn >= len(turns)-1:
			UI.force_pause(true)
			$TurnTimer.set_paused(true)


func jumpToTurn(new_turn):
	if (ready):
		turn = new_turn
		UI.update_turn_num(turn)
		T_Map.resetGrid()
		for t_key in terrain[turn]:
			T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["position"])
		
		for i in range(len(actors)):
			actors[i].instantMoveTo(turns[turn]["characters"][str(i)]["position"])
			actors[i].setIsZombie(turns[turn]["characters"][str(i)]["isZombie"])
		
		if new_turn >= len(turns)-1:
			#UI.force_pause(true)
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


# Testing function
func _on_FileDialog_file_selected(path):
	var file = File.new()
	file.open(path, File.READ)
	gamelog = parse_json(file.get_as_text())
	
	for i in range(gamelog["setup"]["totalCharacters"]):
		var new_actor = actor.instance()
		get_parent().add_child(new_actor)
		actors.push_back(new_actor)
	
	for i in range(gamelog["setup"]["turns"]+1):
		if (i > 0):
			terrain.append(terrain[i-1].duplicate())
		else:
			terrain.append({})
		for t_key in gamelog["turns"][i]["terrain"]:
			terrain[i][t_key] = gamelog["turns"][i]["terrain"][t_key]
	
	
	for i in range(1, len(gamelog["turns"])):
		for a in range(len(actors)):
			if (!gamelog["turns"][i]["characters"].has(str(a))):
				gamelog["turns"][i]["characters"][str(a)] = {}
			if (!gamelog["turns"][i]["characters"][str(a)].has("position")):
				gamelog["turns"][i]["characters"][str(a)]["position"] = gamelog["turns"][i-1]["characters"][str(a)]["position"]
			if (!gamelog["turns"][i]["characters"][str(a)].has("isZombie")):
				gamelog["turns"][i]["characters"][str(a)]["isZombie"] = gamelog["turns"][i-1]["characters"][str(a)]["isZombie"]
	turns = gamelog["turns"]
	


	for t_key in terrain[0]:
		T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["position"])
	
	for i in range(gamelog["setup"]["totalCharacters"]):
		actors[i].instantMoveTo(gamelog["turns"][0]["characters"][str(i)]["position"])
		actors[i].setIsZombie(gamelog["turns"][0]["characters"][str(i)]["isZombie"])
	
	UI.change_max_turns(gamelog["setup"]["turns"])
	UI.show()
	ready = true
	nextTurn()
