extends Node2D

signal forced_pause(paused)
signal restart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var UI = $"../CanvasLayer/UI"
onready var T_Map = $"../TileMap"
onready var actor = preload("res://Game/Player.tscn")

var turn_time = Global.TOTAL_TURN_TIME

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
				if (actors[i].converting):
					str_out += ", converting"
			else:
				str_out += "Human, "
				# add class here
				str_out += character_dict[str(i)]['class'].capitalize() +", "
				str_out += str(character_dict[str(i)]['health']) + " health"
			# remove this for launch
			str_out += ", id: " + str(i)
			str_out += "\n"
	
	var terr = $"../TileMap".getTerrain(info_coord)
	if terr != null:
		if terr[1] == -1:
			str_out += terr[0]
		else:
			str_out += terr[0] + ", " + str(terr[1]) + " health"
		str_out += ", id: " + str(terr[2])
	
	UI.update_info_box(str_out, info_coord)


func reset():
	UI.update_turn_num(0)
	jumpToTurn(0)
	nextTurn()

func nextTurn():
	turn += 1
	$TurnTimer.start(turn_time)
	if ready:
		UI.update_turn_num(turn)
		updateInfoCoord(null)
		var character_dict = turns[turn]["characters"]
		
		# Moving
		for i in range(len(actors)):
			actors[i].resetArrows()
			if (character_dict[str(i)]["isZombie"]):
				if (turn >= 2 and turns[turn-2]["characters"][str(i)]["isZombie"]):
					actors[i].setIsZombie(true, false)
				if (character_dict[str(i)]["isStunned"]):
					actors[i].stun(true)
			actors[i].moveTo(character_dict[str(i)]["position"])
		UI.update_minimap(turns[turn]["characters"])
		yield(get_tree().create_timer(turn_time/3), "timeout")
			
		# Attacking
		var zleft = 0
		var hleft = 0
		for i in range(len(actors)):
			if character_dict[str(i)]["isZombie"]:
				zleft += 1
			else:
				hleft += 1
			if character_dict[str(i)].has("attackAction") and character_dict[str(i)]["attackAction"] != null:
				var attackedID = character_dict[str(i)]["attackAction"]["attackingId"]
				if character_dict[str(i)]["attackAction"]["type"] == "TERRAIN": 
					var pos = Vector2(terrain[turn][attackedID]["position"]["x"], terrain[turn][attackedID]["position"]["y"])
					if actors[i].my_class == "DEMOLITIONIST":
						$"../TileMap".hurtTerrain(pos, 3, attackedID)
					else:
						$"../TileMap".hurtTerrain(pos, 1, attackedID)
					pos.x = pos.x*Global.BOARD_TILESIZE + Global.BOARD_X_OFFSET
					pos.y = pos.y*Global.BOARD_TILESIZE + Global.BOARD_Y_OFFSET
					actors[i].attack(pos)
				elif character_dict[str(i)]["attackAction"]["type"] == "CHARACTER":
					actors[i].attack(actors[int(attackedID)].position)
					if character_dict[str(i)]["isZombie"] and character_dict[attackedID]["isZombie"]:
						actors[int(attackedID)].die()
					else:
						actors[int(attackedID)].hurt()
		UI.update_num_left(zleft, hleft)
		yield(get_tree().create_timer(turn_time/4), "timeout")
		
		# Abilities and finish attacks
		for i in range(len(actors)):
			actors[i].resetArrows()
			if character_dict[str(i)].has("abilityAction") and character_dict[str(i)]["abilityAction"] != null:
				var ability = character_dict[str(i)]["abilityAction"]
				if (ability["type"] == "HEAL"):
					actors[i].ability(actors[int(ability["characterIdTarget"])].position)
				elif (ability["type"] == "BUILD_BARRICADE"):
					var pos = Vector2(ability["positionalTarget"]["x"], ability["positionalTarget"]["y"]) * Global.BOARD_TILESIZE
					actors[i].ability(pos)
		
		# ensure terrain is correct
		for t_key in terrain[turn]:
			var terr_info = terrain[turn][t_key]
			var t_health = 0
			if (!terr_info["destroyed"]):
				t_health = terr_info["health"]
			T_Map.setTerrain(terr_info["imageId"], terr_info["health"], terr_info["position"], t_key)
		
		yield(get_tree().create_timer(turn_time/4), "timeout")
		for i in range(len(actors)):
			actors[i].resetArrows()
		
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
			var t_health = 0
			if (!terrain[turn][t_key]["destroyed"]):
				t_health = terrain[turn][t_key]["health"]
			T_Map.setTerrain(terrain[turn][t_key]["imageId"], t_health, terrain[turn][t_key]["position"], t_key)
		
		var character_dict = turns[turn]["characters"]
		var zleft = 0
		var hleft = 0
		for i in range(len(actors)):
			actors[i].instantMoveTo(character_dict[str(i)]["position"])
			if (character_dict[str(i)]["isZombie"]):
				if (turn >= 1 and !turns[turn-1]["characters"][str(i)]["isZombie"]):
					actors[i].die()
				elif (turn >= 2 and !turns[turn-2]["characters"][str(i)]["isZombie"]):
					actors[i].die()
				else:
					actors[i].setIsZombie(true)
				zleft+=1
			else:
				actors[i].setIsZombie(false)
				hleft+=1
			actors[i].stun(character_dict[str(i)]["isStunned"])
			
			actors[i].resetArrows()
			if character_dict[str(i)].has("abilityAction") and character_dict[str(i)]["abilityAction"] != null:
				var ability = character_dict[str(i)]["abilityAction"]
				if (ability["type"] == "HEAL"):
					actors[i].ability(actors[int(ability["characterIdTarget"])].position)
				elif (ability["type"] == "BUILD_BARRICADE"):
					var pos = Vector2(ability["positionalTarget"]["x"], ability["positionalTarget"]["y"]) * Global.BOARD_TILESIZE
					actors[i].ability(pos)
			
			if character_dict[str(i)].has("attackAction") and character_dict[str(i)]["attackAction"] != null:
				var attackedID = character_dict[str(i)]["attackAction"]["attackingId"]
				if character_dict[str(i)]["attackAction"]["type"] == "TERRAIN": 
					var pos = Vector2(terrain[turn][attackedID]["position"]["x"], terrain[turn][attackedID]["position"]["y"])
					pos.x = pos.x*Global.BOARD_TILESIZE + Global.BOARD_X_OFFSET
					pos.y = pos.y*Global.BOARD_TILESIZE + Global.BOARD_Y_OFFSET
					actors[i].attack(pos)
				elif character_dict[str(i)]["attackAction"]["type"] == "CHARACTER":
					actors[i].attack(actors[int(attackedID)].position)
			
			
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
	
	var board_size = gamelog["setup"]["boardSize"]
	T_Map.updateGridSize(board_size)

	for t_key in terrain[0]:
		T_Map.setTerrain(terrain[turn][t_key]["imageId"], terrain[turn][t_key]["health"], terrain[turn][t_key]["position"], t_key)
	
	turns = gamelog["turns"]
	for i in range(gamelog["setup"]["totalCharacters"]):
		actors[i].instantMoveTo(gamelog["turns"][0]["characters"][str(i)]["position"])
		actors[i].setIsZombie(gamelog["turns"][0]["characters"][str(i)]["isZombie"])
		actors[i].setClass(gamelog["turns"][0]["characters"][str(i)]["class"])
	
	# Set up UI
	UI.change_max_turns(gamelog["stats"]["turns"])
	UI.update_score(gamelog["scores"]["zombies"], gamelog["scores"]["humans"])
	var err_str = ""
	for err in gamelog["errors"]["humanErrors"]:
		err_str += err + "\n"
	for err in gamelog["errors"]["zombieErrors"]:
		err_str += err + "\n"
	UI.log_error(err_str)
	#UI.update_num_left(gamelog["stats"]["zombiesLeft"], gamelog["stats"]["humansLeft"])
	UI.show()
	
	ready = true
	nextTurn()


func _on_FileSelect_file_loaded(GameLog, Terrain):
	startup(GameLog, Terrain)
