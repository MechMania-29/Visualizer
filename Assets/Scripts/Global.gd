extends Node

const BOARD_TILESIZE = 10
const BOARD_X_OFFSET = 0
const BOARD_Y_OFFSET = 0

signal gamelog_verification_start
signal gamelog_verification_complete
signal gamelog_verification_failed
signal progress_text_changed
signal progress_changed

var GameLog : Dictionary
var Terrain : Array

# HTML5/JS detection
onready var use_js = OS.get_name() == "HTML5" and OS.has_feature('JavaScript')

func _ready():
	set_process(false)


# Starts gamelog verification process
func verify_GameLog(_gamelog):
	
	#if !_valid_keys(_gamelog): 
	#	emit_signal("gamelog_verification_failed")
	#	return
	GameLog = _gamelog
	Terrain = []
	
	emit_signal("gamelog_verification_start")
	
	# DO VERIFICATION HERE
	if (false):
		if (!GameLog.has("stats") or typeof(GameLog["stats"]) != TYPE_DICTIONARY):
			emit_signal("gamelog_verification_failed")
			return
		var test = GameLog["stats"]
		if !test.has("turns") or !test.has("humansLeft") or !test.has("zombiesLeft"):
			emit_signal("gamelog_verification_failed")
			return
		
		if !GameLog.has("setup") or typeof(GameLog["setup"]) != TYPE_DICTIONARY:
			emit_signal("gamelog_verification_failed")
			return
		test = GameLog["setup"]
		if !test.has("maxTurns") or !test.has("totalCharacters"):
			emit_signal("gamelog_verification_failed")
			return
		
		if !GameLog.has("turns") or typeof(GameLog["turns"]) != TYPE_ARRAY:
			emit_signal("gamelog_verification_failed")
			return
		test = GameLog["turns"]
		if !test.has("characters") or typeof(test["characters"]) != TYPE_DICTIONARY:
			emit_signal("gamelog_verification_failed")
			return
		if !test.has("terrain") or typeof(test["terrain"]) != TYPE_DICTIONARY:
			emit_signal("gamelog_verification_failed")
			return
		
		test = GameLog["turns"]["characters"]
		
	
	# populate terrain
	for i in range(GameLog["stats"]["turns"]+1):
		if (i > 0):
			Terrain.append(Terrain[i-1].duplicate())
		else:
			Terrain.append({})
		for t_key in GameLog["turns"][i]["terrain"]:
			if Terrain[i].has(t_key):
				for update_key in GameLog["turns"][i]["terrain"][t_key]:
					Terrain[i][t_key][update_key] = GameLog["turns"][i]["terrain"][t_key][update_key]
			else:
				Terrain[i][t_key] = GameLog["turns"][i]["terrain"][t_key]
	
	# populate characters
	for i in range(1, len(GameLog["turns"])):
		for a in range(GameLog["setup"]["totalCharacters"]):
			if (!GameLog["turns"][i]["characters"].has(str(a))):
				GameLog["turns"][i]["characters"][str(a)] = {}
			for c_key in GameLog["turns"][i-1]["characters"][str(a)]:
				if (!GameLog["turns"][i]["characters"][str(a)].has(c_key)):
					GameLog["turns"][i]["characters"][str(a)][c_key] = GameLog["turns"][i-1]["characters"][str(a)][c_key]
		#	if (!gamelog["turns"][i]["characters"][str(a)].has("isZombie")):
		#		gamelog["turns"][i]["characters"][str(a)]["isZombie"] = gamelog["turns"][i-1]["characters"][str(a)]["isZombie"]
	
	#yield(get_tree().create_timer(1.0), "timeout")

	emit_signal("gamelog_verification_complete")
